# Phase 487 Docker Backend Recovery Summary

Generated from `.runtime/docker_backend_recovery_diagnose.txt`.

## Command Health

### docker version
```
Client:
 Version:           29.1.3
 API version:       1.52
 Go version:        go1.25.5
 Git commit:        f52814d
 Built:             Fri Dec 12 14:48:46 2025
 OS/Arch:           darwin/arm64
 Context:           desktop-linux
EOF
exit=1
```

### docker info
```
exit=124
TIMEOUT: docker info did not complete within 20s
```

### docker ps
```
EOF
exit=1
```

### docker system df
```
retrieving disk usage: EOF
exit=1
```

## Log Signals

### Host log matches
```
FILE: /Users/marcela-dev/Library/Containers/com.docker.docker/Data/log/host/com.docker.virtualization.log
[2026-03-09T18:39:10.006350000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-03-09T18:39:10.006381000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-03-10T18:24:02.246186000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-03-10T18:24:02.246216000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-03-10T22:04:47.758330000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-03-10T22:04:47.758363000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-03-11T02:04:08.182475000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-03-11T02:04:08.182901000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-03-11T18:32:24.605838000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-03-11T18:32:24.605867000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-04-06T02:55:08.996797000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-04-06T02:55:08.996833000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-04-07T00:26:19.134719000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-04-07T00:26:19.134750000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-04-07T03:00:24.658871000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-04-07T03:00:24.658899000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-04-07T16:35:20.714227000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-04-07T16:35:20.714328000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-04-07T16:40:55.414666000Z][com.docker.virtualization] VM has stopped: Internal Virtualization error. The virtual machine stopped unexpectedly.
[2026-04-07T16:40:55.415018000Z][com.docker.virtualization] Searching for crashes after error Internal Virtualization error. The virtual machine stopped unexpectedly.
[2026-04-07T16:42:59.808146000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-04-07T16:42:59.808177000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-04-07T17:02:59.847361000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-04-07T17:02:59.847388000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-04-09T17:32:44.829205000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-04-09T17:32:44.829232000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-04-14T03:32:34.016407000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-04-14T03:32:34.016432000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-04-15T21:49:31.035836000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-04-15T21:49:31.035898000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-04-16T18:16:04.703527000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-04-16T18:16:04.703669000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-04-17T17:30:10.845147000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-04-17T17:30:10.845176000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-04-17T17:40:26.234940000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-04-17T17:40:26.234967000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-04-17T21:04:59.058122000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-04-17T21:04:59.058153000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
[2026-04-18T19:25:54.621303000Z][com.docker.virtualization] Disk 0 (<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw) caching is enabled
[2026-04-18T19:25:54.621333000Z][com.docker.virtualization] Disk 1 (/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img) caching is enabled
FILE: /Users/marcela-dev/Library/Containers/com.docker.docker/Data/log/host/electron-ui-console-2026-04-21.log
2026-04-21T16:50:46.136Z error 	Error invoking remote method 'extensions.getMarketplaceCategories__wrapped': Error: An object could not be cloned.
Error: Error invoking remote method 'extensions.getMarketplaceCategories__wrapped': Error: An object could not be cloned.
FILE: /Users/marcela-dev/Library/Containers/com.docker.docker/Data/log/host/com.docker.backend.log.3.gz
Binary file /Users/marcela-dev/Library/Containers/com.docker.docker/Data/log/host/com.docker.backend.log.3.gz matches
FILE: /Users/marcela-dev/Library/Containers/com.docker.docker/Data/log/host/monitor.log.1.gz
Binary file /Users/marcela-dev/Library/Containers/com.docker.docker/Data/log/host/monitor.log.1.gz matches
FILE: /Users/marcela-dev/Library/Containers/com.docker.docker/Data/log/host/electron-ui-console-2026-04-20.log
2026-04-20T18:17:44.959Z error 	Error invoking remote method 'extensions.getMarketplaceCategories__wrapped': Error: An object could not be cloned.
Error: Error invoking remote method 'extensions.getMarketplaceCategories__wrapped': Error: An object could not be cloned.
2026-04-20T21:04:38.685Z error 	Error invoking remote method 'extensions.getMarketplaceCategories__wrapped': Error: An object could not be cloned.
Error: Error invoking remote method 'extensions.getMarketplaceCategories__wrapped': Error: An object could not be cloned.
2026-04-21T01:33:33.161Z error 	Error invoking remote method 'extensions.getMarketplaceCategories__wrapped': Error: An object could not be cloned.
Error: Error invoking remote method 'extensions.getMarketplaceCategories__wrapped': Error: An object could not be cloned.
FILE: /Users/marcela-dev/Library/Containers/com.docker.docker/Data/log/host/monitor.log.5
[2026-04-17T21:04:59.785664000Z] [21:04:59.780116000Z][main.analytics.tracker] sending event: eventEngineState 0b012f5b-35e6-49ab-876a-6562d62f0170
[2026-04-17T21:04:59.785667000Z] [21:04:59.780394000Z][main.analytics.tracker] sending event: eventEngineState 0b012f5b-35e6-49ab-876a-6562d62f0170
[2026-04-17T21:04:59.799528000Z] [21:04:59.792836000Z][main.analytics.tracker] sending event: eventEngineState 29e91768-72d0-4ecb-a4a0-11fd56657240
[2026-04-17T21:04:59.802643000Z] [21:04:59.792946000Z][main.analytics.tracker] sending event: eventEngineState 29e91768-72d0-4ecb-a4a0-11fd56657240
[2026-04-17T21:04:59.840666000Z] [21:04:59.840552000Z][main.analytics.tracker] sending event: eventScreenSize d7c7df68-2443-40d8-9a85-dc48a1356c04
[2026-04-17T21:04:59.842825000Z] [21:04:59.841449000Z][main.analytics.tracker] sending event: eventScreenSize d7c7df68-2443-40d8-9a85-dc48a1356c04
[2026-04-17T21:04:59.951015000Z] [21:04:59.950820000Z][main.engines          ] setting engine linux/virtualization-framework state starting -> running
[2026-04-17T21:04:59.951283000Z] [21:04:59.950900000Z][main.events           ] adding server timestamp to event (engines): 1776459899950897000 docker: running
[2026-04-17T21:04:59.951875000Z] [21:04:59.950881000Z][main                  ] com.docker.virtualization: Waiting for &exec.Cmd{Path:"/Applications/Docker.app/Contents/MacOS/com.docker.virtualization", Args:[]string{"/Applications/Docker.app/Contents/MacOS/com.docker.virtualization", "--kernel", "/Applications/Docker.app/Contents/Resources/linuxkit/kernel", "--cmdline", "init=/initd loglevel=1 root=/dev/vdb rootfstype=erofs ro vsyscall=emulate panic=0 eth0.dhcp eth1.dhcp linuxkit.unified_cgroup_hierarchy=1 console=hvc0   virtio_net.disable_csum=1 vpnkit.connect=connect://2/1999", "--boot", "/Applications/Docker.app/Contents/Resources/linuxkit/desktop.img", "--disk", "<HOME>/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw", "--networkType", "gvisor", "--cpus", "10", "--memoryMiB", "8092", "--console-log", "<HOME>/Library/Containers/com.docker.docker/Data/log/vm/console.log", "--watchdog", "--virtiofs", "/Users", "--virtiofs", "/Volumes", "--virtiofs", "/private", "--virtiofs", "/tmp", "--virtiofs", "/var/folders", "--rosetta"}, Env:[]string(nil), Dir:"", Stdin:(*os.File)(0x140010488f8), Stdout:(*io.PipeWriter)(0x14000d16d20), Stderr:(*io.PipeWriter)(0x14000d16d80), ExtraFiles:[]*os.File(nil), SysProcAttr:(*syscall.SysProcAttr)(nil), Process:(*os.Process)(0x14000d12f00), ProcessState:(*os.ProcessState)(nil), ctx:(*context.valueCtx)(0x1400164ce70), Err:error(nil), Cancel:(func() error)(nil), WaitDelay:5000000000, childIOFiles:[]io.Closer(nil), parentIOPipes:[]io.Closer{(*os.File)(0x14001048940), (*os.File)(0x14001048990)}, goroutine:[]func() error(nil), goroutineErr:(<-chan error)(0x1400054eaf0), ctxResult:(<-chan exec.ctxResult)(0x140004393b0), createdByStack:[]uint8(nil), lookPathErr:error(nil), cachedLookExtensions:struct { in string; out string }{in:"", out:""}}
[2026-04-17T21:04:59.951937000Z] [21:04:59.950986000Z][main.apiproxy         ] engine is running, clearing any previous engine error
[2026-04-17T21:04:59.951951000Z] [21:04:59.951074000Z][main.state            ] backend state changed to running
[2026-04-17T21:04:59.952107000Z] [21:04:59.951231000Z][main.ipcstream        ] 5d36a20e-BackendAPI /engine/state --> 2026-04-17T14:04:59.950897000-07:00 (3a739959) engine running:
[2026-04-17T21:04:59.952171000Z] [21:04:59.951960000Z][main.state            ] sending desktop state:EngineRunningState
[2026-04-17T21:04:59.952692000Z] [21:04:59.952419000Z][main.enginedependencies] starting forwarding dials
[2026-04-17T21:04:59.952721000Z] [21:04:59.952677000Z][main.engines          ] engine linux/virtualization-framework is running
[2026-04-17T21:04:59.953374000Z] [21:04:59.952793000Z][main.ipc              ] (8b7359ad-0) f8735c65-volume-contents C->S DockerVolumeServer GET /ping
[2026-04-17T21:04:59.953614000Z] [21:04:59.953207000Z][main.enginedependencies] starting metrics port exposure
[2026-04-17T21:04:59.953940000Z] [21:04:59.953560000Z][main.enginedependencies] no metrics-addr in daemon.json: not exposing a metrics port
[2026-04-17T21:04:59.965068000Z] [21:04:59.962234000Z][main.heartbeat        ] settings data added: ExtensionsEnabled, OnlyMarketplaceExtensions, DefaultNetworkingMode, DNSInhibition, AutoPauseTimeoutSeconds, AutomaticUpdates, DiskSizeMiB, KubernetesMode, KubernetesNodesCount, KubernetesNodesVersion, LicenseTermsVersion, NetworkType, SharedFolders, ShowAnnouncementNotifications, ShowGeneralNotifications, ShowPromotionalNotifications, ShowSurveyNotifications, TotalDiskSize, UseContainerdSnapshotter, UseDockerAI, UseDockerMCPToolkit, UseInference, UseGrpcfuse, UsePrivilegedComponent, UseResourceSaver, UseVirtualizationFramework, UseVirtualizationFrameworkRosetta, UseVirtualizationFrameworkVirtioFS, UseVpnkit, UsingCloudCLI, VmCPUs, VmMemoryMiB, VmSwapMiB, Modules
[2026-04-17T21:04:59.970837000Z] [21:04:59.969811000Z][main.ipc              ] (8b7359ad-0) f8735c65-volume-contents C<-S 84fe8ee3-volume-contents GET /ping (16.739667ms): {"serverTime":1776459899959126300}
[2026-04-17T21:04:59.971133000Z] [21:04:59.970427000Z][main.ipc              ] (8b7359ad-1) f8735c65-volume-contents C->S DockerVolumeServer GET /metrics
[2026-04-17T21:05:00.023252000Z] [21:05:00.022799000Z][main.ipc              ][W] (8b7359ad-1) f8735c65-volume-contents C<-S 84fe8ee3-volume-contents GET /metrics (52.398875ms): open /var/lib/docker/volumes: no such file or directory
[2026-04-17T21:05:00.023256000Z] [21:05:00.023205000Z][main.heartbeat        ] volume-contents data added: Modules
[2026-04-17T21:05:00.509969000Z] [21:05:00.509907000Z][main.sys              ] onApplicationDidFinishLaunching
[2026-04-17T21:05:00.953644000Z] {"component":"apiproxy","level":"info","msg":"<< HEAD /_ping Internal Server Error: connect tcp 192.168.65.7:2376: connection was refused (997.540416ms)","time":"2026-04-17T14:05:00.953574000-07:00"}
[2026-04-17T21:05:00.954021000Z] [21:05:00.953983000Z][main.heartbeat        ] dockerengine data added: <none>
[2026-04-17T21:05:00.955652000Z] [21:05:00.955559000Z][main.analytics.tracker] sending event: dailyHeartbeat bf7649ba-8412-4842-afdf-03df1cdd5c4e
[2026-04-17T21:05:00.955707000Z] [21:05:00.955601000Z][main.analytics.tracker] sending event: dailyHeartbeat bf7649ba-8412-4842-afdf-03df1cdd5c4e
[2026-04-17T21:05:02.509806000Z] [21:05:02.508487000Z][main.extensions       ] Docker engine is ready
[2026-04-17T21:05:02.556374000Z] {"component":"apiproxy","level":"info","msg":"<< POST /grpc","time":"2026-04-17T14:05:02.510484000-07:00","user_agent":"Go-http-client/1.1"}
[2026-04-17T21:05:02.556515000Z] [21:05:02.515075000Z][main.volumesharer     ] switching to com.docker.backend
[2026-04-17T21:05:02.556629000Z] [21:05:02.525943000Z][main.ipc              ] (d5835f22-0) 1bc77603-volume C->S socketforward GET /list
[2026-04-17T21:05:02.556639000Z] {"component":"apiproxy","level":"info","msg":">> GET /networks/f7d801111540cd03cbde870c6c0d36adf7817bb83b7b12fb837e2d0917d3610e","time":"2026-04-17T14:05:02.528270000-07:00","user_agent":"DockerDesktopUI"}
[2026-04-17T21:05:02.556647000Z] {"component":"apiproxy","level":"info","msg":">> GET /system/df","time":"2026-04-17T14:05:02.530360000-07:00","user_agent":"DockerDesktopUI"}
[2026-04-17T21:05:02.556649000Z] {"component":"apiproxy","level":"info","msg":">> GET /volumes","time":"2026-04-17T14:05:02.530645000-07:00","user_agent":"DockerDesktopUI"}
[2026-04-17T21:05:02.556668000Z] [21:05:02.538617000Z][main.ipc              ] (d5835f22-0) 1bc77603-volume C<-S aeb38b6c-socketforwarder GET /list (12.666166ms): &[]
[2026-04-17T21:05:02.556670000Z] {"component":"apiproxy","level":"info","msg":"<< GET /networks/f7d801111540cd03cbde870c6c0d36adf7817bb83b7b12fb837e2d0917d3610e","time":"2026-04-17T14:05:02.538965000-07:00","user_agent":"DockerDesktopUI"}
[2026-04-17T21:05:02.556675000Z] {"component":"apiproxy","level":"info","msg":">> POST /grpc","time":"2026-04-17T14:05:02.542874000-07:00","user_agent":"desktop-build/v0.29.0 go/1.24.9 darwin/arm64"}
[2026-04-17T21:05:02.556681000Z] {"component":"apiproxy","level":"info","msg":"<< GET /volumes","time":"2026-04-17T14:05:02.543588000-07:00","user_agent":"DockerDesktopUI"}
[2026-04-17T21:05:02.556686000Z] {"component":"apiproxy","level":"info","msg":">> POST /grpc","time":"2026-04-17T14:05:02.545022000-07:00","user_agent":"desktop-build/v0.29.0 go/1.24.9 darwin/arm64"}
[2026-04-17T21:05:02.556696000Z] {"component":"apiproxy","level":"info","msg":"<< POST /grpc","time":"2026-04-17T14:05:02.547868000-07:00","user_agent":"desktop-build/v0.29.0 go/1.24.9 darwin/arm64"}
[2026-04-17T21:05:02.556704000Z] {"component":"apiproxy","level":"info","msg":"<< POST /grpc","time":"2026-04-17T14:05:02.547969000-07:00","user_agent":"desktop-build/v0.29.0 go/1.24.9 darwin/arm64"}
[2026-04-17T21:05:02.581036000Z] {"component":"apiproxy","level":"info","msg":">> POST /grpc","time":"2026-04-17T14:05:02.576334000-07:00","user_agent":"desktop-build/v0.29.0 go/1.24.9 darwin/arm64"}
[2026-04-17T21:05:02.581039000Z] {"component":"apiproxy","level":"info","msg":">> POST /grpc","time":"2026-04-17T14:05:02.576573000-07:00","user_agent":"desktop-build/v0.29.0 go/1.24.9 darwin/arm64"}
[2026-04-17T21:05:02.748653000Z] [21:05:02.743711000Z][main.ipc              ] (6e516cf2) c366ed70-desktop_extensions S->C Docker-Desktop/4.55.0 (Mac; arm64; GUI) GET /store/categories (89.458µs): {"ci-cd":"CI/CD","cloud-deployment":"Cloud Deployment","cloud-development":"Cloud Development","container-orchestration":"Container Orchestration","database":"Database","kubernetes":"Kubernetes","networking":"Networking","registry":"Image Registry","security":"Security","testing-tools":"Testing Tools","utility-tools":"Utility tools","volumes":"Volumes"}
[2026-04-17T21:05:02.769009000Z] [21:05:02.768035000Z][main.extensions       ] invalid URL in com.docker.extension.publisher-url for extension virag/redis-enterprise-docker-extension:0.1.0: [{"title":"GitHub", "url":"https://github.com/redis-field-engineering/redis-enterprise-docker-extension/"}]
[2026-04-17T21:05:02.775655000Z] {"component":"apiproxy","level":"info","msg":">> POST /grpc","time":"2026-04-17T14:05:02.774940000-07:00","user_agent":"desktop-build/v0.29.0 go/1.24.9 darwin/arm64"}
[2026-04-17T21:05:02.778627000Z] {"component":"apiproxy","level":"info","msg":"<< POST /grpc","time":"2026-04-17T14:05:02.778353000-07:00","user_agent":"desktop-build/v0.29.0 go/1.24.9 darwin/arm64"}
[2026-04-17T21:05:02.781209000Z] {"component":"apiproxy","level":"info","msg":">> POST /grpc","time":"2026-04-17T14:05:02.781151000-07:00","user_agent":"desktop-build/v0.29.0 go/1.24.9 darwin/arm64"}
[2026-04-17T21:05:02.786525000Z] {"component":"apiproxy","level":"info","msg":"<< POST /grpc","time":"2026-04-17T14:05:02.786457000-07:00","user_agent":"desktop-build/v0.29.0 go/1.24.9 darwin/arm64"}
[2026-04-17T21:05:02.919704000Z] [21:05:02.919654000Z][main.otelmgr          ] collector starting: system[] user[<HOME>/.docker/run/user-analytics.otlp.grpc.sock]
[2026-04-17T21:05:03.057696000Z] {"component":"apiproxy","level":"info","msg":"<< GET /system/df","time":"2026-04-17T14:05:03.057638000-07:00","user_agent":"DockerDesktopUI"}
[2026-04-17T21:05:03.058211000Z] [21:05:03.057885000Z][main.ipc              ] (6e516cf2) c366ed70-desktop_extensions S->C Docker-Desktop/4.55.0 (Mac; arm64; GUI) GET /store/categories (174.792µs): {"ci-cd":"CI/CD","cloud-deployment":"Cloud Deployment","cloud-development":"Cloud Development","container-orchestration":"Container Orchestration","database":"Database","kubernetes":"Kubernetes","networking":"Networking","registry":"Image Registry","security":"Security","testing-tools":"Testing Tools","utility-tools":"Utility tools","volumes":"Volumes"}
[2026-04-17T21:05:03.095778000Z] [21:05:03.095655000Z][main.extensions       ] invalid URL in com.docker.extension.publisher-url for extension virag/redis-enterprise-docker-extension:0.1.0: [{"title":"GitHub", "url":"https://github.com/redis-field-engineering/redis-enterprise-docker-extension/"}]
[2026-04-17T21:05:03.301211000Z] [21:05:03.300840000Z][main.ipc              ] (6e516cf2) c366ed70-desktop_extensions S->C Docker-Desktop/4.55.0 (Mac; arm64; GUI) GET /store/categories (111.667µs): {"ci-cd":"CI/CD","cloud-deployment":"Cloud Deployment","cloud-development":"Cloud Development","container-orchestration":"Container Orchestration","database":"Database","kubernetes":"Kubernetes","networking":"Networking","registry":"Image Registry","security":"Security","testing-tools":"Testing Tools","utility-tools":"Utility tools","volumes":"Volumes"}
[2026-04-17T21:05:58.907957000Z] [21:05:58.907895000Z][main.cmdline          ] checking launch daemon
[2026-04-17T21:06:02.535155000Z] {"component":"apiproxy","level":"info","msg":">> GET /networks/f7d801111540cd03cbde870c6c0d36adf7817bb83b7b12fb837e2d0917d3610e","time":"2026-04-17T14:06:02.525289000-07:00","user_agent":"DockerDesktopUI"}
[2026-04-17T21:06:02.535187000Z] {"component":"apiproxy","level":"info","msg":"<< GET /networks/f7d801111540cd03cbde870c6c0d36adf7817bb83b7b12fb837e2d0917d3610e","time":"2026-04-17T14:06:02.531326000-07:00","user_agent":"DockerDesktopUI"}
[2026-04-17T21:06:21.428354000Z] {"component":"apiproxy","level":"info","msg":">> GET /v1.51/volumes/motherboard_systems_hq_pgdata","time":"2026-04-17T14:06:21.428335000-07:00","user_agent":"compose/v2.40.3-desktop.1"}
[2026-04-17T21:06:21.429317000Z] {"component":"apiproxy","level":"info","msg":"<< GET /v1.51/volumes/motherboard_systems_hq_pgdata","time":"2026-04-17T14:06:21.429269000-07:00","user_agent":"compose/v2.40.3-desktop.1"}
[2026-04-17T21:06:21.441229000Z] {"component":"apiproxy","level":"info","msg":">> GET /v1.51/containers/json?all=1&filters=%7B%22label%22%3A%7B%22com.docker.compose.oneoff%3DFalse%22%3Atrue%2C%22com.docker.compose.project%3Dmotherboard_systems_hq%22%3Atrue%7D%7D","time":"2026-04-17T14:06:21.441208000-07:00","user_agent":"compose/v2.40.3-desktop.1"}
[2026-04-17T21:06:21.451822000Z] {"component":"apiproxy","level":"info","msg":"<< GET /v1.51/containers/json?all=1&filters=%7B%22label%22%3A%7B%22com.docker.compose.oneoff%3DFalse%22%3Atrue%2C%22com.docker.compose.project%3Dmotherboard_systems_hq%22%3Atrue%7D%7D","time":"2026-04-17T14:06:21.451739000-07:00","user_agent":"compose/v2.40.3-desktop.1"}
[2026-04-17T21:06:21.455279000Z] {"component":"volume","level":"warning","msg":"hostPathOfVolume motherboard_systems_hq_pgdata failed, skipping bind","time":"2026-04-17T14:06:21.455245000-07:00"}
[2026-04-17T21:06:21.455343000Z] [21:06:21.455260000Z][main.volumesharer     ] grpcfuseClient.VolumeApprove([host=,VM=motherboard_systems_hq_pgdata,dst=/var/lib/postgresql/data,option=rw])
```

### VM log matches
```
FILE: /Users/marcela-dev/Library/Containers/com.docker.docker/Data/log/vm/console.log.18.gz
Binary file /Users/marcela-dev/Library/Containers/com.docker.docker/Data/log/vm/console.log.18.gz matches
FILE: /Users/marcela-dev/Library/Containers/com.docker.docker/Data/log/vm/console.log.13
INFO[12356] time="2026-04-16T07:14:14.894732219Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.32MB.events\""  component=containerd
INFO[12356] time="2026-04-16T07:14:14.894797428Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.64KB.events\""  component=containerd
INFO[12356] time="2026-04-16T07:14:14.894874803Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.1GB.events\""  component=containerd
INFO[12364] >> GET /networks/f7d801111540cd03cbde870c6c0d36adf7817bb83b7b12fb837e2d0917d3610e  component=apiproxy user_agent=DockerDesktopUI
INFO[12364] << GET /networks/f7d801111540cd03cbde870c6c0d36adf7817bb83b7b12fb837e2d0917d3610e  component=apiproxy user_agent=DockerDesktopUI
INFO[12364] time="2026-04-16T07:14:22.883471751Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.2MB.events\""  component=containerd
INFO[12364] time="2026-04-16T07:14:22.883517751Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.32MB.events\""  component=containerd
INFO[12364] time="2026-04-16T07:14:22.883555001Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.64KB.events\""  component=containerd
INFO[12364] time="2026-04-16T07:14:22.883577126Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.1GB.events\""  component=containerd
INFO[12365] time="2026-04-16T07:14:23.886773709Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.2MB.events\""  component=containerd
INFO[12365] time="2026-04-16T07:14:23.886903501Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.32MB.events\""  component=containerd
INFO[12365] time="2026-04-16T07:14:23.886974918Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.64KB.events\""  component=containerd
INFO[12365] time="2026-04-16T07:14:23.887053376Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.1GB.events\""  component=containerd
INFO[12365] time="2026-04-16T07:14:23.888702626Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.2MB.events\""  component=containerd
INFO[12365] time="2026-04-16T07:14:23.888779918Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.32MB.events\""  component=containerd
INFO[12365] time="2026-04-16T07:14:23.888814376Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.64KB.events\""  component=containerd
INFO[12365] time="2026-04-16T07:14:23.888842876Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.1GB.events\""  component=containerd
INFO[12366] time="2026-04-16T07:14:24.891751835Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.2MB.events\""  component=containerd
INFO[12366] time="2026-04-16T07:14:24.891847751Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.32MB.events\""  component=containerd
INFO[12366] time="2026-04-16T07:14:24.891901418Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.64KB.events\""  component=containerd
INFO[12366] time="2026-04-16T07:14:24.892009460Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.1GB.events\""  component=containerd
INFO[12374] time="2026-04-16T07:14:32.886199547Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.2MB.events\""  component=containerd
INFO[12374] time="2026-04-16T07:14:32.886232755Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.32MB.events\""  component=containerd
INFO[12374] time="2026-04-16T07:14:32.886248547Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.64KB.events\""  component=containerd
INFO[12374] time="2026-04-16T07:14:32.886261339Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.1GB.events\""  component=containerd
INFO[12375] time="2026-04-16T07:14:33.890515172Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.2MB.events\""  component=containerd
INFO[12375] time="2026-04-16T07:14:33.890632964Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.32MB.events\""  component=containerd
INFO[12375] time="2026-04-16T07:14:33.890703756Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.64KB.events\""  component=containerd
INFO[12375] time="2026-04-16T07:14:33.890781756Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.1GB.events\""  component=containerd
INFO[12375] time="2026-04-16T07:14:33.892446839Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.2MB.events\""  component=containerd
INFO[12375] time="2026-04-16T07:14:33.892622631Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.32MB.events\""  component=containerd
INFO[12375] time="2026-04-16T07:14:33.892751214Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.64KB.events\""  component=containerd
INFO[12375] time="2026-04-16T07:14:33.892794964Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.1GB.events\""  component=containerd
INFO[12376] time="2026-04-16T07:14:34.896300965Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.2MB.events\""  component=containerd
INFO[12376] time="2026-04-16T07:14:34.896428048Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.32MB.events\""  component=containerd
INFO[12376] time="2026-04-16T07:14:34.896513548Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.64KB.events\""  component=containerd
INFO[12376] time="2026-04-16T07:14:34.896592381Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.1GB.events\""  component=containerd
INFO[12384] time="2026-04-16T07:14:42.892150552Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.2MB.events\""  component=containerd
INFO[12384] time="2026-04-16T07:14:42.892201385Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.32MB.events\""  component=containerd
INFO[12384] time="2026-04-16T07:14:42.892219302Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.64KB.events\""  component=containerd
INFO[12384] time="2026-04-16T07:14:42.892235302Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.1GB.events\""  component=containerd
INFO[12385] time="2026-04-16T07:14:43.899337427Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.2MB.events\""  component=containerd
INFO[12385] time="2026-04-16T07:14:43.899444677Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.32MB.events\""  component=containerd
INFO[12385] time="2026-04-16T07:14:43.899501552Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.64KB.events\""  component=containerd
INFO[12385] time="2026-04-16T07:14:43.899548344Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.1GB.events\""  component=containerd
INFO[12385] time="2026-04-16T07:14:43.901410719Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.2MB.events\""  component=containerd
INFO[12385] time="2026-04-16T07:14:43.901472261Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.32MB.events\""  component=containerd
INFO[12385] time="2026-04-16T07:14:43.901498969Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.64KB.events\""  component=containerd
INFO[12385] time="2026-04-16T07:14:43.901523177Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.1GB.events\""  component=containerd
INFO[12386] time="2026-04-16T07:14:44.904956969Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.2MB.events\""  component=containerd
INFO[12386] time="2026-04-16T07:14:44.905080178Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.32MB.events\""  component=containerd
INFO[12386] time="2026-04-16T07:14:44.905217053Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.64KB.events\""  component=containerd
INFO[12386] time="2026-04-16T07:14:44.905311844Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.1GB.events\""  component=containerd
INFO[12394] time="2026-04-16T07:14:52.891374001Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.2MB.events\""  component=containerd
INFO[12394] time="2026-04-16T07:14:52.891413501Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.32MB.events\""  component=containerd
INFO[12394] time="2026-04-16T07:14:52.891429917Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.64KB.events\""  component=containerd
INFO[12394] time="2026-04-16T07:14:52.891446751Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.1GB.events\""  component=containerd
INFO[12395] time="2026-04-16T07:14:53.899049376Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.2MB.events\""  component=containerd
INFO[12395] time="2026-04-16T07:14:53.899187793Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.32MB.events\""  component=containerd
INFO[12395] time="2026-04-16T07:14:53.899260584Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.64KB.events\""  component=containerd
INFO[12395] time="2026-04-16T07:14:53.899342376Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.1GB.events\""  component=containerd
INFO[12395] time="2026-04-16T07:14:53.902598376Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.2MB.events\""  component=containerd
INFO[12395] time="2026-04-16T07:14:53.902671668Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.32MB.events\""  component=containerd
INFO[12395] time="2026-04-16T07:14:53.902704751Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.64KB.events\""  component=containerd
INFO[12395] time="2026-04-16T07:14:53.902743584Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.1GB.events\""  component=containerd
INFO[12396] time="2026-04-16T07:14:54.911588835Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.2MB.events\""  component=containerd
INFO[12396] time="2026-04-16T07:14:54.911738835Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.32MB.events\""  component=containerd
INFO[12396] time="2026-04-16T07:14:54.911810251Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.64KB.events\""  component=containerd
INFO[12396] time="2026-04-16T07:14:54.911898710Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.1GB.events\""  component=containerd
INFO[12404] time="2026-04-16T07:15:02.894391089Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.2MB.events\""  component=containerd
INFO[12404] time="2026-04-16T07:15:02.894429964Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.32MB.events\""  component=containerd
INFO[12404] time="2026-04-16T07:15:02.894448714Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.64KB.events\""  component=containerd
INFO[12404] time="2026-04-16T07:15:02.894795547Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.1GB.events\""  component=containerd
INFO[12405] time="2026-04-16T07:15:03.901765214Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.2MB.events\""  component=containerd
INFO[12405] time="2026-04-16T07:15:03.901886631Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.32MB.events\""  component=containerd
INFO[12405] time="2026-04-16T07:15:03.901957297Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.64KB.events\""  component=containerd
INFO[12405] time="2026-04-16T07:15:03.902045881Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.1GB.events\""  component=containerd
INFO[12405] time="2026-04-16T07:15:03.903865464Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.2MB.events\""  component=containerd
INFO[12405] time="2026-04-16T07:15:03.903960464Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.32MB.events\""  component=containerd
INFO[12405] time="2026-04-16T07:15:03.904002631Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.64KB.events\""  component=containerd
INFO[12405] time="2026-04-16T07:15:03.904041547Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.1GB.events\""  component=containerd
INFO[12406] time="2026-04-16T07:15:04.912050048Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.2MB.events\""  component=containerd
INFO[12406] time="2026-04-16T07:15:04.912165715Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.32MB.events\""  component=containerd
INFO[12406] time="2026-04-16T07:15:04.912243923Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.64KB.events\""  component=containerd
INFO[12406] time="2026-04-16T07:15:04.912318798Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.1GB.events\""  component=containerd
INFO[12414] time="2026-04-16T07:15:12.895928718Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.2MB.events\""  component=containerd
INFO[12414] time="2026-04-16T07:15:12.895963593Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.32MB.events\""  component=containerd
INFO[12414] time="2026-04-16T07:15:12.895980385Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.64KB.events\""  component=containerd
INFO[12414] time="2026-04-16T07:15:12.896001427Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.1GB.events\""  component=containerd
INFO[12415] time="2026-04-16T07:15:13.901343927Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.2MB.events\""  component=containerd
INFO[12415] time="2026-04-16T07:15:13.901524302Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.32MB.events\""  component=containerd
INFO[12415] time="2026-04-16T07:15:13.901610844Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.64KB.events\""  component=containerd
INFO[12415] time="2026-04-16T07:15:13.901661011Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.1GB.events\""  component=containerd
INFO[12415] time="2026-04-16T07:15:13.903034969Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.2MB.events\""  component=containerd
INFO[12415] time="2026-04-16T07:15:13.903102802Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.32MB.events\""  component=containerd
INFO[12415] time="2026-04-16T07:15:13.903132427Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.64KB.events\""  component=containerd
INFO[12415] time="2026-04-16T07:15:13.903171719Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.1GB.events\""  component=containerd
INFO[12416] time="2026-04-16T07:15:14.909495469Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.2MB.events\""  component=containerd
INFO[12416] time="2026-04-16T07:15:14.909586511Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.32MB.events\""  component=containerd
INFO[12416] time="2026-04-16T07:15:14.909643636Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.64KB.events\""  component=containerd
INFO[12416] time="2026-04-16T07:15:14.909720553Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.1GB.events\""  component=containerd
INFO[12424] >> GET /networks/f7d801111540cd03cbde870c6c0d36adf7817bb83b7b12fb837e2d0917d3610e  component=apiproxy user_agent=DockerDesktopUI
INFO[12424] << GET /networks/f7d801111540cd03cbde870c6c0d36adf7817bb83b7b12fb837e2d0917d3610e  component=apiproxy user_agent=DockerDesktopUI
INFO[12424] time="2026-04-16T07:15:22.896658834Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.2MB.events\""  component=containerd
INFO[12424] time="2026-04-16T07:15:22.896708459Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.32MB.events\""  component=containerd
INFO[12424] time="2026-04-16T07:15:22.896723042Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.64KB.events\""  component=containerd
INFO[12424] time="2026-04-16T07:15:22.896742584Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.1GB.events\""  component=containerd
INFO[12425] time="2026-04-16T07:15:23.899511626Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.2MB.events\""  component=containerd
INFO[12425] time="2026-04-16T07:15:23.899601293Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.32MB.events\""  component=containerd
INFO[12425] time="2026-04-16T07:15:23.899664543Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.64KB.events\""  component=containerd
INFO[12425] time="2026-04-16T07:15:23.899747459Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/ac8beb3924d3c44c583a786f05ce756d845e53ccb4bf9e56e1a4ea050e74266b/hugetlb.1GB.events\""  component=containerd
INFO[12425] time="2026-04-16T07:15:23.901901001Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.2MB.events\""  component=containerd
INFO[12425] time="2026-04-16T07:15:23.901994084Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.32MB.events\""  component=containerd
INFO[12425] time="2026-04-16T07:15:23.902028709Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.64KB.events\""  component=containerd
INFO[12425] time="2026-04-16T07:15:23.902067084Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.1GB.events\""  component=containerd
INFO[12426] time="2026-04-16T07:15:24.904279585Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.2MB.events\""  component=containerd
INFO[12426] time="2026-04-16T07:15:24.904365668Z" level=error msg="unable to parse \"max 0\" as a uint from Cgroup file \"/sys/fs/cgroup/docker/094199273d1e4118fdefbdbf038d48c8059887d4da4d9c812a502f22475b8f1a/hugetlb.32MB.events\""  component=containerd
```

