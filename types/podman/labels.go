package podman

import "strings"

const SystemdUnitLabel = "PODMAN_SYSTEMD_UNIT"

func QuadletUnit(labels map[string]string) string {
	unit := labels[SystemdUnitLabel]
	if strings.HasPrefix(unit, "podman-compose@") {
		return ""
	}
	return unit
}
