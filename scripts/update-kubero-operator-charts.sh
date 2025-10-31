#!/usr/bin/env bash
set -euo pipefail

CHART_NAME="kubero-operator"
CHART_VERSION="${1:-latest}"
INSTALL_URL="https://raw.githubusercontent.com/kubero-dev/kubero-operator/refs/heads/main/deploy/operator.yaml"
mkdir -p charts
rm -rf charts/"$CHART_NAME" || true

curl -L "$INSTALL_URL" -o patches/install.yaml
kubectl kustomize patches |helmify -crd-dir -preserve-ns charts/$CHART_NAME
rm -rf patches/install.yaml

(
  cd charts
  if  [ "$CHART_VERSION" != "latest" ]; then
    HELM_VERSION=${CHART_VERSION#v}
    sed -i .bak -e "s/^version:.*/version: $CHART_VERSION/g" $CHART_NAME/Chart.yaml
    sed -i .bak -e "s/^appVersion:.*/appVersion: \"$CHART_VERSION\"/g" $CHART_NAME/Chart.yaml
    rm $CHART_NAME/Chart.yaml.bak
  fi
)
echo "Helm chart in charts/$CHART_NAME"
