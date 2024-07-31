export $(cat .env)

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
    echo "Proceeding..."
    # Add your command here
    echo "kubectl apply -f deployment.yaml"
    envsubst < deployment.yaml | kubectl apply -f -
    echo "kubectl apply -f service.yaml"
    envsubst < service.yaml | kubectl apply -f -
    echo "kubectl apply -f ingress.yaml"
    envsubst < ingress.yaml | kubectl apply -f -
    ;;
  n|N ) 
    echo "Aborting..."
    ;;
  * ) 
    echo "Invalid input - use y or n"
    ;;
esac

