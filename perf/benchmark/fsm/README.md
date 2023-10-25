
```bash
cd ../benchmark/fsm
./setup_fsm.sh <fsm-release-version>
```

```bash
kubectl -n fsm-system get deploy
```

```bash
export NAMESPACE=twopods-fsm
export DNS_DOMAIN=local
export LINKERD_INJECT=enabled
cd ..
./setup_test.sh
```