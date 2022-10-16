package tests

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type InfraTerratestSuite struct {
	suite.Suite
	tfOptions  *terraform.Options
	k8sOptions *k8s.KubectlOptions
}

func (suite *InfraTerratestSuite) SetupSuite() {
	contextName := "kind-ambient"
	namespace := "istio-system"
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

	t := suite.T()
	output := terraform.InitAndPlan(t, suite.tfOptions)
	resourceCount := terraform.GetResourceCount(t, output)
	assert.Equalf(
		t,
		resourceCount.Add+resourceCount.Change+resourceCount.Destroy,
		0,
		"There are resources that will be modified, exiting!",
	)
}

func (suite *InfraTerratestSuite) TestComponentsAreReady() {
	t := suite.T()
	// Assert all the daemonset replicas are passing the readiness probes
	assert.Eventually(t, func() bool {
		cniDs := k8s.GetDaemonSet(t, suite.k8sOptions, "istio-cni-node")
		return cniDs.Status.DesiredNumberScheduled == cniDs.Status.NumberAvailable
	}, 2*time.Minute, 5*time.Second, "The istio-cni daemonset replicas are not available!")

	assert.Eventually(t, func() bool {
		ztunnelDs := k8s.GetDaemonSet(t, suite.k8sOptions, "ztunnel")
		return ztunnelDs.Status.DesiredNumberScheduled == ztunnelDs.Status.NumberAvailable
	}, 2*time.Minute, 5*time.Second, "The ztunnel daemonset replicas are not available!")

	// Ensure that the replicasets of the istio components are passing th readiness probes
	for _, rs := range k8s.ListReplicaSets(t, suite.k8sOptions, v1.ListOptions{
		LabelSelector: "istio.io/rev=default",
	}) {
		assert.Equalf(
			t,
			rs.Status.Replicas,
			rs.Status.AvailableReplicas,
			"The replicas of the %s replicaset are not available!",
			rs.Name,
		)
	}

	gatewaySvc := k8s.GetService(t, suite.k8sOptions, "istio-ingressgateway")

	// Assert that the istio ingress gateway has an external ip defined
	assert.NotEmptyf(
		t,
		gatewaySvc.Status.LoadBalancer.Ingress,
		"The istio-ingressgateway doesn't have and external IP defined!",
	)
}

func TestOpsTerratestSuite(t *testing.T) {
	suite.Run(t, new(InfraTerratestSuite))
}
