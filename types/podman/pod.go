package podman

import (
	"time"

	"github.com/getarcaneapp/arcane/types/v2/base"
)

type PodContainer struct {
	ID           string `json:"id"`
	Names        string `json:"names"`
	Status       string `json:"status"`
	RestartCount uint   `json:"restartCount"`
}

type Pod struct {
	base.EnvironmentTag

	ID         string            `json:"id"`
	Name       string            `json:"name"`
	Namespace  string            `json:"namespace,omitempty"`
	Status     string            `json:"status"`
	Created    time.Time         `json:"created"`
	InfraID    string            `json:"infraId,omitempty"`
	Cgroup     string            `json:"cgroup,omitempty"`
	Labels     map[string]string `json:"labels,omitempty"`
	Networks   []string          `json:"networks,omitempty"`
	Containers []PodContainer    `json:"containers"`
}

type PodPortBinding struct {
	HostIP   string `json:"hostIp,omitempty"`
	HostPort string `json:"hostPort"`
}

type PodInfraConfig struct {
	PortBindings       map[string][]PodPortBinding `json:"portBindings,omitempty"`
	HostNetwork        bool                        `json:"hostNetwork"`
	StaticIP           string                      `json:"staticIp,omitempty"`
	StaticMAC          string                      `json:"staticMac,omitempty"`
	NoManageResolvConf bool                        `json:"noManageResolvConf"`
	DNSServer          []string                    `json:"dnsServer,omitempty"`
	DNSSearch          []string                    `json:"dnsSearch,omitempty"`
	DNSOption          []string                    `json:"dnsOption,omitempty"`
	NoManageHostname   bool                        `json:"noManageHostname"`
	NoManageHosts      bool                        `json:"noManageHosts"`
	HostAdd            []string                    `json:"hostAdd,omitempty"`
	HostsFile          string                      `json:"hostsFile,omitempty"`
	Networks           []string                    `json:"networks,omitempty"`
	NetworkOptions     map[string][]string         `json:"networkOptions,omitempty"`
	PidNS              string                      `json:"pidNs,omitempty"`
	UserNS             string                      `json:"userNs,omitempty"`
	UtsNS              string                      `json:"utsNs,omitempty"`
}

type PodInspectContainer struct {
	ID       string           `json:"id"`
	Name     string           `json:"name"`
	State    string           `json:"state"`
	Image    string           `json:"image,omitempty"`
	Status   string           `json:"status,omitempty"`
	Created  time.Time        `json:"created"`
	ExitCode int32            `json:"exitCode"`
	IsInfra  bool             `json:"isInfra"`
	Ports    []PodPortMapping `json:"ports,omitempty"`
}

type PodMount struct {
	Type        string   `json:"type"`
	Name        string   `json:"name,omitempty"`
	Source      string   `json:"source,omitempty"`
	Destination string   `json:"destination"`
	Driver      string   `json:"driver,omitempty"`
	Mode        string   `json:"mode,omitempty"`
	Options     []string `json:"options,omitempty"`
	RW          bool     `json:"rw"`
	Propagation string   `json:"propagation,omitempty"`
	SubPath     string   `json:"subPath,omitempty"`
}

type PodDevice struct {
	PathOnHost        string `json:"pathOnHost"`
	PathInContainer   string `json:"pathInContainer"`
	CgroupPermissions string `json:"cgroupPermissions,omitempty"`
}

type PodWeightDevice struct {
	Path   string `json:"path"`
	Weight uint16 `json:"weight"`
}

type PodThrottleDevice struct {
	Path string `json:"path"`
	Rate uint64 `json:"rate"`
}

type PodInspect struct {
	ID                 string                `json:"id"`
	Name               string                `json:"name"`
	Namespace          string                `json:"namespace,omitempty"`
	Created            time.Time             `json:"created"`
	State              string                `json:"state"`
	CreateCommand      []string              `json:"createCommand,omitempty"`
	ExitPolicy         string                `json:"exitPolicy,omitempty"`
	RestartPolicy      string                `json:"restartPolicy,omitempty"`
	Hostname           string                `json:"hostname,omitempty"`
	Labels             map[string]string     `json:"labels,omitempty"`
	CreateCgroup       bool                  `json:"createCgroup"`
	CgroupParent       string                `json:"cgroupParent,omitempty"`
	CgroupPath         string                `json:"cgroupPath,omitempty"`
	CreateInfra        bool                  `json:"createInfra"`
	InfraContainerID   string                `json:"infraContainerId,omitempty"`
	InfraConfig        *PodInfraConfig       `json:"infraConfig,omitempty"`
	SharedNamespaces   []string              `json:"sharedNamespaces,omitempty"`
	NumContainers      uint                  `json:"numContainers"`
	Containers         []PodInspectContainer `json:"containers"`
	CPUPeriod          uint64                `json:"cpuPeriod,omitempty"`
	CPUQuota           int64                 `json:"cpuQuota,omitempty"`
	CPUShares          uint64                `json:"cpuShares,omitempty"`
	CPUSetCPUs         string                `json:"cpusetCpus,omitempty"`
	CPUSetMems         string                `json:"cpusetMems,omitempty"`
	MemoryLimit        uint64                `json:"memoryLimit,omitempty"`
	MemorySwap         uint64                `json:"memorySwap,omitempty"`
	BlkioWeight        uint64                `json:"blkioWeight,omitempty"`
	BlkioWeightDevices []PodWeightDevice     `json:"blkioWeightDevices,omitempty"`
	DeviceReadBps      []PodThrottleDevice   `json:"deviceReadBps,omitempty"`
	DeviceWriteBps     []PodThrottleDevice   `json:"deviceWriteBps,omitempty"`
	Mounts             []PodMount            `json:"mounts,omitempty"`
	Devices            []PodDevice           `json:"devices,omitempty"`
	VolumesFrom        []string              `json:"volumesFrom,omitempty"`
	SecurityOpts       []string              `json:"securityOpts,omitempty"`
}

type PodPortMapping struct {
	ContainerPort uint16 `json:"containerPort" minimum:"1" doc:"Port inside the pod"`
	HostPort      uint16 `json:"hostPort,omitempty" doc:"Port on the host"`
	HostIP        string `json:"hostIp,omitempty" doc:"Host IP to bind"`
	Protocol      string `json:"protocol,omitempty" doc:"tcp, udp, or sctp"`
	Range         uint16 `json:"range,omitempty" doc:"Number of consecutive ports to map"`
}

type PodNetwork struct {
	Name          string   `json:"name" minLength:"1" doc:"Network to join"`
	Aliases       []string `json:"aliases,omitempty" doc:"Network-scoped aliases"`
	StaticIPs     []string `json:"staticIps,omitempty" doc:"Static IPv4 or IPv6 addresses"`
	StaticMAC     string   `json:"staticMac,omitempty" doc:"Static MAC address"`
	InterfaceName string   `json:"interfaceName,omitempty" doc:"Interface name inside the pod"`
}

type PodVolume struct {
	Source      string   `json:"source" minLength:"1" doc:"Absolute host path or named volume"`
	Destination string   `json:"destination" minLength:"1" doc:"Path inside the pod"`
	Options     []string `json:"options,omitempty" doc:"Mount options such as ro, z, Z, or U"`
}

type PodDeviceLimit struct {
	Device string `json:"device" minLength:"1" doc:"Block device as MAJOR:MINOR"`
	Value  string `json:"value" minLength:"1" doc:"Weight (10-1000) for weight limits, or a rate such as 1mb for throughput limits"`
}

type PodCreateRequest struct {
	Name               string            `json:"name" minLength:"1" doc:"Pod name"`
	Hostname           string            `json:"hostname,omitempty" doc:"Pod hostname"`
	Labels             map[string]string `json:"labels,omitempty" doc:"Pod labels"`
	ExitPolicy         string            `json:"exitPolicy,omitempty" enum:"continue,stop" doc:"Behaviour when the last container exits"`
	RestartPolicy      string            `json:"restartPolicy,omitempty" enum:"no,always,on-failure,unless-stopped" doc:"Restart policy for containers in the pod"`
	RestartRetries     *uint             `json:"restartRetries,omitempty" doc:"Restart attempts for the on-failure policy"`
	NoInfra            bool              `json:"noInfra,omitempty" doc:"Create the pod without an infra container"`
	InfraImage         string            `json:"infraImage,omitempty" doc:"Image for the infra container"`
	InfraCommand       []string          `json:"infraCommand,omitempty" doc:"Entrypoint of the infra container"`
	InfraName          string            `json:"infraName,omitempty" doc:"Name of the infra container"`
	InfraConmonPidFile string            `json:"infraConmonPidFile,omitempty" doc:"Path that receives the infra container's conmon PID"`
	SharedNamespaces   []string          `json:"sharedNamespaces,omitempty" doc:"Namespaces shared between pod members"`
	ShareParent        *bool             `json:"shareParent,omitempty" doc:"Use the pod's cgroup as the cgroup parent of its containers"`
	Pid                string            `json:"pid,omitempty" doc:"PID namespace: host, private, ns:<path>, or container:<id>"`
	Ipc                string            `json:"ipc,omitempty" doc:"IPC namespace: host, private, shareable, none, ns:<path>, or container:<id>"`
	Uts                string            `json:"uts,omitempty" doc:"UTS namespace: host, private, ns:<path>, or container:<id>"`
	Userns             string            `json:"userns,omitempty" doc:"User namespace, for example auto, keep-id, keep-id:uid=1000, host, or ns:<path>"`
	UIDMap             []string          `json:"uidMap,omitempty" doc:"UID mappings as CONTAINER:HOST:SIZE"`
	GIDMap             []string          `json:"gidMap,omitempty" doc:"GID mappings as CONTAINER:HOST:SIZE"`
	NetworkMode        string            `json:"networkMode,omitempty" doc:"bridge, host, none, private, slirp4netns, pasta, or ns:<path>"`
	NetworkOptions     []string          `json:"networkOptions,omitempty" doc:"Options for the slirp4netns or pasta network mode"`
	Networks           []PodNetwork      `json:"networks,omitempty" doc:"Networks to join"`
	PortMappings       []PodPortMapping  `json:"portMappings,omitempty" doc:"Published ports"`
	DNSServers         []string          `json:"dnsServers,omitempty" doc:"DNS servers"`
	DNSSearch          []string          `json:"dnsSearch,omitempty" doc:"DNS search domains"`
	DNSOptions         []string          `json:"dnsOptions,omitempty" doc:"DNS resolver options"`
	NoManageResolvConf bool              `json:"noManageResolvConf,omitempty" doc:"Use the image's /etc/resolv.conf"`
	AddHosts           []string          `json:"addHosts,omitempty" doc:"Extra /etc/hosts entries as HOST:IP"`
	NoHosts            bool              `json:"noHosts,omitempty" doc:"Use the image's /etc/hosts"`
	NoHostname         bool              `json:"noHostname,omitempty" doc:"Use the image's /etc/hostname"`
	HostsFile          string            `json:"hostsFile,omitempty" doc:"Base file for /etc/hosts, or image or none"`
	CgroupParent       string            `json:"cgroupParent,omitempty" doc:"Parent cgroup of the pod"`
	CPUs               float64           `json:"cpus,omitempty" minimum:"0" doc:"Number of CPUs"`
	CPUShares          uint64            `json:"cpuShares,omitempty" doc:"Relative CPU weight"`
	CPUSetCPUs         string            `json:"cpusetCpus,omitempty" doc:"CPUs allowed to run the pod, for example 0-3"`
	CPUSetMems         string            `json:"cpusetMems,omitempty" doc:"Memory nodes allowed to run the pod, for example 0,1"`
	Memory             string            `json:"memory,omitempty" doc:"Memory limit such as 512m or 2g"`
	MemorySwap         string            `json:"memorySwap,omitempty" doc:"Memory plus swap limit such as 1g, or -1 for unlimited swap"`
	BlkioWeight        uint16            `json:"blkioWeight,omitempty" minimum:"10" maximum:"1000" doc:"Relative block IO weight"`
	BlkioWeightDevices []PodDeviceLimit  `json:"blkioWeightDevices,omitempty" doc:"Per-device block IO weights"`
	DeviceReadBps      []PodDeviceLimit  `json:"deviceReadBps,omitempty" doc:"Per-device read rate limits"`
	DeviceWriteBps     []PodDeviceLimit  `json:"deviceWriteBps,omitempty" doc:"Per-device write rate limits"`
	Devices            []string          `json:"devices,omitempty" doc:"Host devices as HOST[:CONTAINER[:PERMISSIONS]]"`
	GPUs               []string          `json:"gpus,omitempty" doc:"NVIDIA GPUs to add through CDI, or all"`
	Volumes            []PodVolume       `json:"volumes,omitempty" doc:"Bind mounts and named volumes"`
	VolumesFrom        []string          `json:"volumesFrom,omitempty" doc:"Containers to mount volumes from, as CONTAINER[:OPTIONS]"`
	ShmSize            string            `json:"shmSize,omitempty" doc:"Size of /dev/shm such as 64m"`
	ShmSizeSystemd     string            `json:"shmSizeSystemd,omitempty" doc:"Size of systemd tmpfs mounts such as 64m"`
	SecurityOpt        []string          `json:"securityOpt,omitempty" doc:"Security options such as label=disable"`
	Sysctl             map[string]string `json:"sysctl,omitempty" doc:"Namespaced kernel parameters"`
}

type PodActionRequest struct {
	Timeout *int   `json:"timeout,omitempty" doc:"Seconds to wait before killing the pod on stop"`
	Signal  string `json:"signal,omitempty" doc:"Signal sent on kill"`
}

type PodCreateResponse struct {
	ID string `json:"id"`
}

type PodStats struct {
	Pod           string `json:"pod"`
	CID           string `json:"cid"`
	Name          string `json:"name"`
	CPU           string `json:"cpu"`
	MemUsage      string `json:"memUsage"`
	MemUsageBytes string `json:"memUsageBytes"`
	Mem           string `json:"mem"`
	NetIO         string `json:"netIo"`
	BlockIO       string `json:"blockIo"`
	PIDS          string `json:"pids"`
}

type PodTop struct {
	Titles    []string   `json:"titles"`
	Processes [][]string `json:"processes"`
}

type PodPruneReport struct {
	ID string `json:"id"`
}

type Container struct {
	ID        string            `json:"id"`
	Names     []string          `json:"names"`
	Image     string            `json:"image"`
	ImageID   string            `json:"imageId,omitempty"`
	State     string            `json:"state"`
	Status    string            `json:"status,omitempty"`
	Created   time.Time         `json:"created"`
	StartedAt int64             `json:"startedAt,omitempty"`
	ExitCode  int32             `json:"exitCode"`
	Exited    bool              `json:"exited"`
	Labels    map[string]string `json:"labels,omitempty"`
	Pod       string            `json:"pod,omitempty"`
	PodName   string            `json:"podName,omitempty"`
	IsInfra   bool              `json:"isInfra"`
	Ports     []PodPortMapping  `json:"ports,omitempty"`
}
