if [ -n "$AGENT_AUTO_REGISTER_KEY" ]; then
  echo "agent.auto.register.key=$AGENT_AUTO_REGISTER_KEY" >> ./config/autoregister.properties
fi

if [ -n "$AGENT_AUTO_REGISTER_RESOURCES" ]; then
  echo "agent.auto.register.resources=$AGENT_AUTO_REGISTER_RESOURCES" >> ./config/autoregister.properties
fi

if [ -n "$AGENT_AUTO_REGISTER_ENVIRONMENTS" ]; then
  echo "agent.auto.register.environments=$AGENT_AUTO_REGISTER_ENVIRONMENTS" >> ./config/autoregister.properties
fi

if [ -n "$AGENT_AUTO_REGISTER_HOSTNAME" ]; then
  echo "agent.auto.register.hostname=$AGENT_AUTO_REGISTER_HOSTNAME" >> ./config/autoregister.properties
fi

# unset variables, so we don't pollute and leak sensitive stuff to the agent process...
unset AGENT_AUTO_REGISTER_KEY AGENT_AUTO_REGISTER_RESOURCES AGENT_AUTO_REGISTER_ENVIRONMENTS AGENT_AUTO_REGISTER_HOSTNAME

exec /go-agent/agent.sh
