package cmd

import (
	"github.com/h-otter/diskless/n0kube-agent/mount"
	"github.com/spf13/cobra"
)

func NewMountCMD() *cobra.Command {
	opts := &mount.MountOptions{}

	cmd := &cobra.Command{
		Use: "mount",
		RunE: func(cmd *cobra.Command, args []string) error {
			return opts.Run()
		},
	}
	cmd.Flags().StringVar(&opts.MountLabel, "mount-label", "n0kube-nvme", "")
	cmd.Flags().StringVar(&opts.TargetPath, "target-path", "/mnt/nvme", "")
	cmd.Flags().StringArrayVar(&opts.ReplacePoints, "replace-points", []string{"/var", "/etc/kubernetes", "/opt/cni/bin", "/etc/cni/net.d", "/usr/libexec/kubernetes"}, "")

	return cmd
}

func init() {
	rootCmd.AddCommand(NewMountCMD())
}
