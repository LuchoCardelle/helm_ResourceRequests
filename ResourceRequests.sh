#!/bin/bash
set -e
DIRWRK="WhiteStack/ch5"


###########################################################
#       --HELP

# Función para mostrar ayuda
show_help() {
  echo "Uso: helm ResourceRequests [solo path del archivo values.yaml]"
  echo "ejemplo : helm ResourceRequests /chart/"
  echo
  echo "Opciones:"
  echo "  --help        Muestra esta ayuda"
  echo "  --version     Muestra la versión del plugin"
  echo
  # Añade aquí más opciones según sea necesario
}

# Comprobar si se ha pasado el argumento --help
if [[ "$1" == "--help" ]]; then
  show_help
  exit 0
fi

# Comprobar si se ha pasado el argumento --version
if [[ "$1" == "--version" ]]; then
  echo "ResourceRequests versión 0.1.0"
  echo
  exit 0
fi

###########################################################
#       START


# Verifica que se haya proporcionado un archivo de Helm Chart
if [ "$#" -ne 1 ]; then
    echo "Usage: resource-summary <chart-path>"
    exit 1
fi

CHART_PATH=$1

# Utiliza yq para extraer y sumar los valores de recursos
CPU_REQUEST_TOTAL=0
MEMORY_REQUEST_TOTAL=0


	CPU_REQUEST=$(helm template "$CHART_PATH" | yq '.spec.template.spec.containers[].resources.requests.cpu')
	MEMORY_REQUEST=$(helm template "$CHART_PATH" | yq '.spec.template.spec.containers[].resources.requests.memory')
	REPLICAS=$(helm template "$CHART_PATH" | grep replicas | sed 's/ //g' | awk -F":" '{print $2}')

	# Suma los recursos solicitados, considerando las réplicas
	CPU_REQUEST_TOTAL=$(echo "$CPU_REQUEST_TOTAL + $(echo "$CPU_REQUEST" | sed 's/m//') * $REPLICAS" | bc)
	MEMORY_REQUEST_TOTAL=$(echo "$MEMORY_REQUEST_TOTAL + $(echo "$MEMORY_REQUEST" | sed 's/Mi//') * $REPLICAS" | bc)

# Muestra el total de recursos solicitados
echo "Total CPU requested: $CPU_REQUEST_TOTAL milli cores"
echo "Total Memory requested: $MEMORY_REQUEST_TOTAL Mi"
