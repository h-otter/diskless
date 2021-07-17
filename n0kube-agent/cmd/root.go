package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use: "n0kube-agent",
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Printf("%v", err)
		os.Exit(1)
	}
}
