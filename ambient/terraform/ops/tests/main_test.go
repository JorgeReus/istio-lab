package tests

import (
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"regexp"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/itchyny/gojq"
	"github.com/prometheus/common/expfmt"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
)

type OpsTerratestSuite struct {
	suite.Suite
	tfOptions  *terraform.Options
	k8sOptions *k8s.KubectlOptions
}

func (suite *OpsTerratestSuite) SetupSuite() {
	contextName := "kind-ambient"
	namespace := "ambient-test"
	suite.k8sOptions = k8s.NewKubectlOptions(contextName, "", namespace)

	retryableErrors := map[string]string{}

	for k, v := range terraform.DefaultRetryableTerraformErrors {
		retryableErrors[k] = v
	}

	suite.tfOptions = &terraform.Options{
		TerraformDir:             "../",
		RetryableTerraformErrors: retryableErrors,
		MaxRetries:               3,
		TimeBetweenRetries:       5 * time.Second,
	}

	terraform.InitAndApplyAndIdempotent(suite.T(), suite.tfOptions)
}

func (suite *OpsTerratestSuite) TearDownSuite() {
	t := suite.T()
	_, err := terraform.DestroyE(t, suite.tfOptions)
	assert.NoError(t, err)
}

func (suite *OpsTerratestSuite) TestProxyConfigDynamicCerts() {
	t := suite.T()

	cmd := shell.Command{
		Command: "istioctl",
		Args:    []string{"pc", "secret", "ds/ztunnel", "-n", "istio-system", "-o", "json"},
		Logger:  logger.Discard,
	}

	output, err := shell.RunCommandAndGetOutputE(t, cmd)
	assert.NoError(t, err)
	query, err := gojq.Parse(
		".dynamicActiveSecrets[0].secret.tlsCertificate.certificateChain.inlineBytes",
	)

	var input map[string]interface{}
	json.Unmarshal([]byte(output), &input)
	assert.NoError(t, err)
	iter := query.Run(input)
	v, ok := iter.Next()
	assert.True(t, ok)
	data, err := base64.StdEncoding.DecodeString(v.(string))
	assert.NoError(t, err)
	block, _ := pem.Decode(data)
	cert, err := x509.ParseCertificate(block.Bytes)
	assert.NoError(t, err)
	// Assert that the issuer is cluster.local
	assert.Equal(t, "O=cluster.local", cert.Issuer.String())
	// Assert that the certificate for an entity lasts 24 hours
	assert.Equal(t, 24, int(cert.NotAfter.Sub(cert.NotBefore).Hours()))
}

func (suite *OpsTerratestSuite) TestK8s() {
	t := suite.T()

	// Assert that the sleep client can reach the ingress gateway
	code, err := RunKubectlAndGetOutputE(
		t,
		suite.k8sOptions,
		"exec",
		"deploy/sleep",
		"--",
		"curl",
		"-s",
		"-o",
		"/dev/null",
		"-I",
		"-w",
		"%{http_code}",
		"http://istio-ingressgateway.istio-system/productpage",
	)

	assert.NoError(t, err)
	assert.NotEqual(t, "503", code)

	// Assert that the sleep client can reach the productpage service
	code, err = RunKubectlAndGetOutputE(
		t,
		suite.k8sOptions,
		"exec",
		"deploy/sleep",
		"--",
		"curl",
		"-s",
		"-o",
		"/dev/null",
		"-I",
		"-w",
		"%{http_code}",
		"http://productpage:9080/",
	)

	assert.NoError(t, err)
	assert.NotEqual(t, "503", code)

	// Assert that we got an access denied from istio using the not sleep client
	resp, err := RunKubectlAndGetOutputE(
		t,
		suite.k8sOptions,
		"exec",
		"deploy/notsleep",
		"--",
		"curl",
		"-s",
		"http://productpage:9080/",
	)

	assert.NoError(t, err)

	assert.Equal(t, "RBAC: access denied", resp)

	// Assert that the waypoint proxy status for the productpage svc is ready
	status, err := RunKubectlAndGetOutputE(
		t,
		suite.k8sOptions,
		"get",
		"gateway",
		"productpage",
		"-o",
		"jsonpath={.status.conditions[0].type}",
	)

	assert.NoError(t, err)

	assert.Equal(t, "Ready", status)

	// Assert that the sleep client cannot call the productpage svc with a DELETE verb
	resp, err = RunKubectlAndGetOutputE(
		t,
		suite.k8sOptions,
		"exec",
		"deploy/sleep",
		"--",
		"curl",
		"-s",
		"http://productpage:9080/",
		"-X",
		"DELETE",
	)

	assert.NoError(t, err)

	assert.Equal(t, "RBAC: access denied", resp)

	// Assert that we're getting prometheus metrics from the productpage waypoint proxy
	metrics, err := RunKubectlAndGetOutputE(
		t,
		suite.k8sOptions,
		"exec",
		"deploy/bookinfo-productpage-waypoint-proxy",
		"--",
		"curl",
		"-s",
		"http://localhost:15020/stats/prometheus",
	)

	metricsReader := strings.NewReader(metrics)
	var parser expfmt.TextParser
	mf, err := parser.TextToMetricFamilies(metricsReader)

	for k, v := range mf {
		assert.Equal(t, k, v.GetName())
	}

	var r = regexp.MustCompile(`(?m)reviews-(?P<Version>v\d)-`)
	// Assert that the traffic is shifting between v1 and v2
	var v1Returned, v2Returned bool
	counter := 0
	tries := 100
	for {
		version_data, err := RunKubectlAndGetOutputE(
			t,
			suite.k8sOptions,
			"exec",
			"deploy/sleep",
			"--",
			"curl",
			"-s",
			"http://istio-ingressgateway.istio-system/productpage",
		)

		assert.NoError(t, err)
		matches := r.FindStringSubmatch(version_data)
		assert.Greater(t, len(matches), 1)
		if matches[1] == "v1" {
			v1Returned = true
		}

		if matches[1] == "v2" {
			v2Returned = true
		}

		if v1Returned && v2Returned {
			break
		}

		if counter > tries {
			t.Fatal("Traffic is not being splitted between v1 and v2")
		}

		counter++
	}
}

func TestOpsTerratestSuite(t *testing.T) {
	suite.Run(t, new(OpsTerratestSuite))
}
