export $(cat .env)

printf '####################################\n'
printf 'The deployment file looks like this: \n'
envsubst < deployment.yaml | cat -
printf "\n\n"

# Prompt the user
read -p "Do you want to proceed DELETING the deployment and ingress? (y/n): " choice

# Process the response
case "$choice" in 
  y|Y ) 
    printf "Proceeding..."
    # Add your command here
    printf "kubectl delete -f deployment.yaml"
    envsubst < deployment.yaml | kubectl delete -f -
    printf "kubectl delete -f service.yaml"
    envsubst < service.yaml | kubectl delete -f -
    printf "kubectl delete -f ingress.yaml"
    envsubst < ingress.yaml | kubectl delete -f -
    ;;
  n|N ) 
    printf "Aborting..."
    ;;
  * ) 
    printf "Invalid input - use y or n"
    ;;
esac

