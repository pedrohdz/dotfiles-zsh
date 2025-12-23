#------------------------------------------------------------------------------
# Other Bash Completion
#------------------------------------------------------------------------------
if [ -n $(type -t _get_comp_words_by_ref) ] \
        && [ -f /etc/bash_completion ]; then
    echo 'WARNING - Defaulting to /etc/bash_completion'
    source /etc/bash_completion
fi

if which aws_completer > /dev/null; then
  builtin complete -C aws_completer aws
fi

if which pip > /dev/null; then
  eval "$(pip completion --timeout 2 --retries 0 --bash \
            | awk '/^# pip.*start/,/^# pip.*end/')"
fi

if which kubectl > /dev/null; then
  source <(kubectl completion bash)
fi

if which minikube > /dev/null; then
  source <(minikube completion bash)
fi

if which helm > /dev/null; then
  source <(helm completion bash)
fi

if which terraform > /dev/null; then
  builtin complete -C terraform terraform
fi
