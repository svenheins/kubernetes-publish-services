export $(cat .env)

BOOL_APPLY_ADDON=false

if [ -f ${APP_PATH}/addon.yaml ]; then
  printf '####################################\n'
  printf "File ${APP_PATH}/addon.yaml exists.\n-> Using additional addon.yaml\n\n "
  printf '####################################\n'
  printf 'The addon file looks like this: \n'
  envsubst < ${APP_PATH}/addon.yaml | cat -
  printf "\n\n"
  BOOL_APPLY_ADDON=true

else
  printf '####################################\n'
  printf "File ${APP_PATH}/addon.yaml does not exist.\n-> Skipping additional addon.yaml\n\n "
fi

printf '####################################\n'
printf 'The deployment file looks like this: \n'
envsubst < deployment.yaml | cat -
printf "\n\n"

printf '####################################\n'
printf 'The service file looks like this: \n'
envsubst < service.yaml | cat -
printf "\n\n"

printf '####################################\n'
printf 'The ingress file looks like this: \n'
envsubst < ingress.yaml | cat -
printf "\n\n"

# Prompt the user
read -p "Do you want to proceed? (y/n): " choice

# Process the response
case "$choice" in 
  y|Y ) 
    printf "Proceeding..."

    if $BOOL_APPLY_ADDON; then
      printf "Applying additional yaml!"
      printf "kubectl apply -f ${APP_PATH}/addon.yaml"
      envsubst < ${APP_PATH}/addon.yaml | kubectl apply -f -
    fi

    printf "kubectl apply -f deployment.yaml"
    envsubst < deployment.yaml | kubectl apply -f -
    printf "kubectl apply -f service.yaml"
    envsubst < service.yaml | kubectl apply -f -
    printf "kubectl apply -f ingress.yaml"
    envsubst < ingress.yaml | kubectl apply -f -
    ;;
  n|N ) 
    printf "Aborting..."
    ;;
  * ) 
    printf "Invalid input - use y or n"
    ;;
esac

