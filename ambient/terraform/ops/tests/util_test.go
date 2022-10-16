package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/shell"
)

func RunKubectlAndGetOutputE(
	t *testing.T,
	options *k8s.KubectlOptions,
	args ...string,
) (string, error) {
	cmdArgs := []string{}
	if options.ContextName != "" {
		cmdArgs = append(cmdArgs, "--context", options.ContextName)
	}
	if options.ConfigPath != "" {
		cmdArgs = append(cmdArgs, "--kubeconfig", options.ConfigPath)
	}
	if options.Namespace != "" {
		cmdArgs = append(cmdArgs, "--namespace", options.Namespace)
	}
	cmdArgs = append(cmdArgs, args...)
	command := shell.Command{
		Command: "kubectl",
		Args:    cmdArgs,
		Env:     options.Env,
		Logger:  logger.Discard,
	}
	return shell.RunCommandAndGetOutputE(t, command)
}
