image_ids_get_cmd="$(cat << EOF
docker image ls -q \
  --filter "label=namespace=${NAMESPACE}" \
  --filter "label=project=${COMPOSE_PROJECT_NAME}" \
  | sort | uniq
EOF
)"

image_ids=$(eval $image_ids_get_cmd)

while read image_id; do
  docker image rm -f ${image_id}
done << EOF
${image_ids}
EOF

docker volume rm ${COMPOSE_PROJECT_NAME}_trinitycore_shallow_clone
