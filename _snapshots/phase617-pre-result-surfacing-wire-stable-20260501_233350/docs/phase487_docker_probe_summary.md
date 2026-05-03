# Phase 487 Docker Probe Summary

Generated: Tue Apr 21 09:54:47 PDT 2026

## Key Findings

### From docker_health_diagnose.txt

---- which docker ----
/usr/local/bin/docker
exit=0

---- docker version ----
Client:
 Version:           29.1.3
 API version:       1.52
 Go version:        go1.25.5
 Git commit:        f52814d
 Built:             Fri Dec 12 14:48:46 2025
 OS/Arch:           darwin/arm64
 Context:           desktop-linux
exit=1

---- docker context ls ----
---- docker context show ----
---- docker info ----

### From docker_health_probe_timeout.txt

---- which docker ----
/usr/local/bin/docker
exit=0

---- docker context show ----
desktop-linux
exit=0

---- docker context inspect desktop-linux ----
[
    {
        "Name": "desktop-linux",
        "Metadata": {
            "Description": "Docker Desktop",
            "GODEBUG": "x509negativeserial=1",
            "otel": {
                "OTEL_EXPORTER_OTLP_ENDPOINT": "unix:///Users/marcela-dev/.docker/run/user-analytics.otlp.grpc.sock"
            }
        },
        "Endpoints": {
            "docker": {
                "Host": "unix:///Users/marcela-dev/.docker/run/docker.sock",
                "SkipTLSVerify": false
            }
        },
        "TLSMaterial": {},
        "Storage": {
            "MetadataPath": "/Users/marcela-dev/.docker/contexts/meta/fe9c6bd7a66301f49ca9b6a70b217107cd1284598bfc254700c989b916da791e",
            "TLSPath": "/Users/marcela-dev/.docker/contexts/tls/fe9c6bd7a66301f49ca9b6a70b217107cd1284598bfc254700c989b916da791e"
        }
    }
]
exit=0

---- docker version (time-bounded) ----
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

---- docker info (time-bounded) ----
exit=124


---- docker ps (time-bounded) ----
EOF
exit=1

---- docker system df (time-bounded) ----
retrieving disk usage: EOF
exit=1

---- filtered docker processes ----
marcela-dev      98808   4.5  0.8 1865762144 126448   ??  S    Sat12PM  16:59.00 /Applications/Docker.app/Contents/MacOS/Docker Desktop.app/Contents/MacOS/Docker Desktop --reason=open-tray --analytics-enabled=true --name=dashboard
marcela-dev      98788   0.5  0.5 412963024  76144   ??  S    Sat12PM   4:02.75 /Applications/Docker.app/Contents/MacOS/com.docker.backend services
marcela-dev      98789   0.1  0.1 411608176  24864   ??  S    Sat12PM   0:04.22 /Applications/Docker.app/Contents/MacOS/com.docker.backend fork
marcela-dev      47506   0.0  0.0 410068880    432 s012  S+    9:43AM   0:00.00 tee .runtime/docker_health_diagnose.txt
marcela-dev      47505   0.0  0.0 410212752    720 s012  S+    9:43AM   0:00.00 bash scripts/phase487_docker_health_diagnose.sh
marcela-dev      47503   0.0  0.0 410203536    976 s012  S+    9:43AM   0:00.00 bash scripts/phase487_docker_health_diagnose.sh
marcela-dev      98835   0.0  0.2 411659472  35760   ??  S    Sat12PM   0:02.26 /Applications/Docker.app/Contents/Resources/bin/cagent api --listen unix:///Users/marcela-dev/Library/Containers/com.docker.docker/Data/docker-cagent.sock --models-gateway https://ai-backend-service.docker.com/proxy?origin=desktop&desktopVersion=4.55.0 --pull-interval 15 docker/gordon
marcela-dev      98829   0.0  0.6 1865335328 105408   ??  S    Sat12PM   1:30.04 /Applications/Docker.app/Contents/MacOS/Docker Desktop.app/Contents/Frameworks/Docker Desktop Helper (Renderer).app/Contents/MacOS/Docker Desktop Helper (Renderer) --type=renderer --user-data-dir=/Users/marcela-dev/Library/Application Support/Docker Desktop --standard-schemes=app --enable-sandbox --secure-schemes=app --fetch-schemes=dd --app-path=/Applications/Docker.app/Contents/MacOS/Docker Desktop.app/Contents/Resources/app.asar --enable-sandbox --lang=en-US --num-raster-threads=4 --enable-zero-copy --enable-gpu-memory-buffer-compositor-resources --enable-main-frame-before-activation --renderer-client-id=4 --time-ticks-at-unix-epoch=-1776483001844568 --launch-time-ticks=57353141205 --shared-files --field-trial-handle=1718379636,r,9938893549645621170,4989922439813329793,262144 --enable-features=PdfUseShowSaveFilePicker,ScreenCaptureKitPickerScreen,ScreenCaptureKitStreamPickerSonoma --disable-features=MacWebContentsOcclusion,ScreenAIOCREnabled,SpareRendererForSitePerProcess,TimeoutHangingVideoCaptureStarts --variations-seed-version --desktop-ui-preload-params={"needsBackendErrorsIpcClient":true,"needsPrimaryIpcClient":true} --seatbelt-client=83
marcela-dev      98826   0.0  0.2 444063232  34704   ??  S    Sat12PM   0:02.42 /Applications/Docker.app/Contents/MacOS/Docker Desktop.app/Contents/Frameworks/Docker Desktop Helper.app/Contents/MacOS/Docker Desktop Helper --type=utility --utility-sub-type=network.mojom.NetworkService --lang=en-US --service-sandbox-type=network --user-data-dir=/Users/marcela-dev/Library/Application Support/Docker Desktop --standard-schemes=app --enable-sandbox --secure-schemes=app --fetch-schemes=dd --shared-files --field-trial-handle=1718379636,r,9938893549645621170,4989922439813329793,262144 --enable-features=PdfUseShowSaveFilePicker,ScreenCaptureKitPickerScreen,ScreenCaptureKitStreamPickerSonoma --disable-features=MacWebContentsOcclusion,ScreenAIOCREnabled,SpareRendererForSitePerProcess,TimeoutHangingVideoCaptureStarts --variations-seed-version --seatbelt-client=21
marcela-dev      98825   0.0  0.3 444350496  49200   ??  S    Sat12PM   0:55.06 /Applications/Docker.app/Contents/MacOS/Docker Desktop.app/Contents/Frameworks/Docker Desktop Helper (GPU).app/Contents/MacOS/Docker Desktop Helper (GPU) --type=gpu-process --user-data-dir=/Users/marcela-dev/Library/Application Support/Docker Desktop --gpu-preferences=UAAAAAAAAAAgAAAEAAAAAAAAAAAAAAAAAABgAAMAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAIAAAAAAAAAAgAAAAAAAAA --shared-files --field-trial-handle=1718379636,r,9938893549645621170,4989922439813329793,262144 --enable-features=PdfUseShowSaveFilePicker,ScreenCaptureKitPickerScreen,ScreenCaptureKitStreamPickerSonoma --disable-features=MacWebContentsOcclusion,ScreenAIOCREnabled,SpareRendererForSitePerProcess,TimeoutHangingVideoCaptureStarts --variations-seed-version --seatbelt-client=38
marcela-dev      98787   0.0  0.2 411615328  25408   ??  S    Sat12PM   0:05.62 /Applications/Docker.app/Contents/MacOS/com.docker.backend
root             65644   0.0  0.0 411883264   1712   ??  Ss   Fri10AM   0:00.07 /Library/PrivilegedHelperTools/com.docker.vmnetd
marcela-dev      48193   0.0  0.2 411460096  28576 s014  S+    9:50AM   0:00.02 /Users/marcela-dev/.docker/cli-plugins/docker-ai docker-cli-plugin-metadata
marcela-dev      48179   0.0  0.0 410068880   1008 s014  S+    9:50AM   0:00.00 tee .runtime/docker_health_probe_timeout.txt
marcela-dev      48178   0.0  0.0 410222992   1520 s014  S+    9:50AM   0:00.00 bash scripts/phase487_docker_health_probe_timeout.sh
marcela-dev      48176   0.0  0.0 410209680   1696 s014  S+    9:50AM   0:00.00 bash scripts/phase487_docker_health_probe_timeout.sh
marcela-dev      47521   0.0  0.2 411431088  25536 s012  S+    9:43AM   0:00.05 /Users/marcela-dev/.docker/cli-plugins/docker-ai docker-cli-plugin-metadata
marcela-dev      47513   0.0  0.1 411350592  21280 s012  S+    9:43AM   0:00.08 docker info
exit=0

---- docker socket visibility ----
srwxr-xr-x  1 marcela-dev  staff  0 Apr 18 12:25 /Users/marcela-dev/.docker/run/docker.sock
exit=0

---- recent Docker Desktop logs (if present) ----
host
vm
exit=0


## Extracted Conclusions

- Docker Desktop processes are present.
- Docker socket exists at /Users/marcela-dev/.docker/run/docker.sock.
- docker version returned client details but did not complete cleanly in the earlier probe.
- docker info appeared to hang or stall in the earlier diagnose run.
- docker system df previously returned: retrieving disk usage: EOF.
- This indicates Docker Desktop/backend is present, but disk-usage inspection is unstable or partially unhealthy.

## Recommended Corridor Status

- Do not prune yet.
- Treat Docker storage classification as blocked by daemon/backend instability.
- Next safe move is targeted Docker Desktop/backend recovery diagnosis, not storage mutation.
