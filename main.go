package main

import (
	"errors"
	"os"

	log "github.com/sirupsen/logrus"
	"github.com/urfave/cli"
	"strings"
)

func init() {
	log.SetOutput(os.Stdout)
	log.SetLevel(log.InfoLevel)
}

func main() {
	app := cli.NewApp()
	app.Name = "env-aws-params"
	app.Usage = "Application entry-point that injects SSM Parameter Store values as Environment Variables"
	app.UsageText = "env-aws-params [global options] -p prefix command [command arguments]"
	app.Flags = cliFlags()
	app.Action = func(c *cli.Context) error {
		return action(c)
	}
	app.Run(os.Args)
}

func cliFlags() []cli.Flag {
	return []cli.Flag{
		cli.StringFlag{
			Name:   "aws-region",
			Usage:  "The AWS region to use for the Parameter Store API",
			EnvVar: "AWS_REGION",
		},
		cli.StringSliceFlag{
			Name:  "prefix, p",
			Usage: "Key prefix that is used to retrieve the environment variables - supports multiple use",
		},
		cli.BoolFlag{
			Name:  "pristine",
			Usage: "Only use values retrieved from Parameter Store, do not inherit the existing environment variables",
		},
		cli.BoolFlag{
			Name:  "basename",
			Usage: "Only use basename of variable path",
		},
		cli.BoolFlag{
			Name:  "sanitize",
			Usage: "Replace invalid characters in keys to underscores",
		},
		cli.BoolFlag{
			Name:  "strip",
			Usage: "Strip invalid characters in keys",
		},
		cli.BoolFlag{
			Name:  "upcase",
			Usage: "Force keys to uppercase",
		},
	}
}

func action(c *cli.Context) error {
	code, err := validateArgs(c)
	if code > 0 {
		return cli.NewExitError(errorPrefix(err), code)
	}

	params, err := getParameters(c)
	if err != nil {
		return cli.NewExitError(errorPrefix(err), code)
	}

	envVars := BuildEnvVars(
		params,
		c.GlobalBool("basename"),
		c.GlobalBool("sanitize"),
		c.GlobalBool("strip"),
		c.GlobalBool("upcase"))

	if c.GlobalBool("pristine") == false {
		envVars = append(os.Environ(), envVars...)
	}

	RunCommand(c.Args()[0], c.Args()[1:], envVars)

	return nil
}

func errorPrefix(err error) string {
	return strings.Join([]string{"ERROR:", err.Error()}, " ")
}

func getParameters(c *cli.Context) (map[string]string, error) {
	values := make(map[string]string)

	client, err := NewSSMClient(c.GlobalString("aws-region"))
	if err != nil {
		return values, err
	}

	for _, path := range c.GlobalStringSlice("prefix") {
		params, err := client.GetParametersByPath(path)
		if err != nil {
			return values, err
		}
		for k, v := range params {
			values[k] = v
		}
	}
	return values, nil
}

func validateArgs(c *cli.Context) (int, error) {
	if len(c.GlobalStringSlice("prefix")) == 0 {
		return 1, errors.New("prefix is required")
	}

	if c.NArg() == 0 {
		return 2, errors.New("command not specified")
	}

	if c.GlobalBool("sanitize") == c.GlobalBool("strip") == true {
		return 3, errors.New("--sanitize and --strip are mutually exclusive behaviors")
	}

	return 0, nil
}
