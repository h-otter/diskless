package mount

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
)

func DevicePathByLabel(label string) string {
	return filepath.Join("/dev/disk/by-label", label)
}

var ERROR_NO_LABELED_DEVICE = fmt.Errorf("no labeled device")

func MountByLabel(label string, target string) error {
	realPath, err := os.Readlink(DevicePathByLabel(label))
	if os.IsNotExist(err) {
		return ERROR_NO_LABELED_DEVICE
	}
	realPath = filepath.Clean(filepath.Join(filepath.Dir(DevicePathByLabel(label)), realPath))

	if err := os.MkdirAll(target, 0755); err != nil {
		return fmt.Errorf(`os.MkdirAll(%s, 0755) %w`, target, err)
	}

	if err := syscall.Mount(realPath, target, "ext4", 0, ""); err != nil {
		return fmt.Errorf(`syscall.Mount("%s", "%s", "ext4", 0, "") %w`, realPath, target, err)
	}
	// TODO: 何故かinvalid argumentになったり，device or resource busyになる
	// c := exec.Command("mount", "-t", "ext4", "-o", "errors=remount-ro", realPath, NVME_TARGET_PATH)
	// if buf, err := c.CombinedOutput(); err != nil {
	// 	return fmt.Errorf(`c="%v".Run() output=%s %w`, c.Args, string(buf), err)
	// }

	return nil
}

var ERROR_INITIALIZED = fmt.Errorf("initialized")

func CopyAndReplace(src, dst string) error {
	overlay := strings.TrimRight(filepath.Join(dst, src), "/")

	initLocker := filepath.Join(dst, strings.ReplaceAll(src, "/", "_")+".initialized")
	if _, err := os.Stat(initLocker); os.IsExist(err) {
		return ERROR_INITIALIZED
	}

	if err := os.RemoveAll(overlay); err != nil {
		return fmt.Errorf(`os.RemoveAll(%s) %w`, overlay, err)
	}

	if _, err := os.Stat(src); os.IsExist(err) {
		if err := os.MkdirAll(filepath.Dir(overlay), 0755); err != nil {
			return fmt.Errorf(`os.MkdirAll(%s, 0755) %w`, filepath.Dir(overlay), err)
		}

		// TODO: Golangにディレクトリコピーの関数がなかったため，コマンドで代用
		c := exec.Command("cp", "-a", src, overlay)
		if buf, err := c.CombinedOutput(); err != nil {
			return fmt.Errorf(`c="%v".Run() output=%s %w`, c.Args, string(buf), err)
		}
	} else {
		if err := os.MkdirAll(src, 0755); err != nil {
			return fmt.Errorf(`os.MkdirAll(%s, 0755) %w`, src, err)
		}
		if err := os.MkdirAll(overlay, 0755); err != nil {
			return fmt.Errorf(`os.MkdirAll(%s, 0755) %w`, overlay, err)
		}
	}

	if _, err := os.Create(initLocker); err != nil {
		return fmt.Errorf("os.Create(initLocker=%s) %w", initLocker, err)
	}

	if err := syscall.Mount(overlay, src, "", syscall.MS_BIND|syscall.MS_REC, ""); err != nil {
		return fmt.Errorf(`syscall.Mount("%s", "%s", "", syscall.MS_BIND|syscall.MS_REC, "") %w`, overlay, src, err)
	}

	return nil
}

type MountOptions struct {
	MountLabel    string
	TargetPath    string
	ReplacePoints []string
}

func (opts *MountOptions) Run() error {
	if err := MountByLabel(opts.MountLabel, opts.TargetPath); err != nil {
		if !errors.Is(err, ERROR_NO_LABELED_DEVICE) {
			return err
		}
	}

	for _, p := range opts.ReplacePoints {
		if err := CopyAndReplace(p, opts.TargetPath); err != nil {
			if !errors.Is(err, ERROR_INITIALIZED) {
				return err
			}
		}
	}

	return nil
}
