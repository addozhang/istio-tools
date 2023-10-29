# Flomesh Service Mesh (FSM) Benchmarking

## 1 - Create cluster

Please follow this [Setup README](https://github.com/istio/tools/tree/master/perf/benchmark#setup), finish step 1.

## 2. Install FSM

```bash
cd ../benchmark/fsm
./setup_fsm.sh <fsm-release-version>
```

Check the components of FSM.

```bash
kubectl -n fsm-system get deploy
```

## 3. Deploy the fortio test environment

```bash
export NAMESPACE=twopods-fsm
export DNS_DOMAIN=local
export LOAD_GEN_TYPE=nighthawk
export FSM_INJECT=enabled
cd ..
./setup_test.sh
```

## 4. Prepare Python Environment

Please follow steps here: [Prepare Python Env](https://github.com/istio/tools/tree/master/perf/benchmark#prepare-python-environment)

```bash
pipenv shell
pipenv install
```

## 5. Run benchmark

Example:

```bash
# Cleanup existing benchmark results
export NAMESPACE=twopods-fsm
FORTIO_CLIENT=$(kubectl get pod -n $NAMESPACE -l app=fortioclient -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n $NAMESPACE $FORTIO_CLIENT -c shell -- bash -c 'rm -f /var/lib/fortio/*.json'

export LOAD_GEN_TYPE=fortio
python runner/runner.py --config_file ./configs/fsm/fsm_latency.yaml

```

6. Extract Fortio latency metrics to CSV

```bash
export NAMESPACE=twopods-fsm
export FORTIO_CLIENT_URL=http://$(kubectl get services -n $NAMESPACE fortioclient -o jsonpath="{.status.loadBalancer.ingress[0].ip}"):9076
kubectl -n fsm-system port-forward svc/fsm-prometheus 7070:7070 &
export PROMETHEUS_URL=http://localhost:7070
python runner/fortio.py $FORTIO_CLIENT_URL --prometheus=$PROMETHEUS_URL --csv "StartTime,ActualDuration,Labels,NumThreads,ActualQPS,p50,p90,p99,p999,cpu_mili_avg_fsm_proxy_fortioclient,cpu_mili_avg_fsm_proxy_fortioserver,mem_Mi_avg_fsm_proxy_fortioclient,mem_Mi_avg_fsm_proxy_fortioserver" --csv_output /tmp/fsm_input.csv
```

7. 

```bash
python ./graph_plotter/graph_plotter.py --graph_type=latency-p50 --x_axis=conn --telemetry_modes=fsm_both,fsm_baseline --query_list=2,4,8,16,32,64 --query_str=ActualQPS==1000 --csv_filepath=/tmp/fsm_input.csv --graph_title=/tmp/fsm_output.png
```