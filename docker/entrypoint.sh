#!/bin/sh
cd ${WORKDIR}

# If config file does not exist, copy over default environmental configuration template 
if [ -f "${DATADIR}/config.ini" ]
  then
    echo "Node config.ini found"
  else
  	echo "Node config.ini not found.  Copying default version"
  	if [ ${ENVIRONMENT} = "test"] 
  	  then
   		cp /test_config.ini ${DATADIR}/config.ini
   	  else
   	    cp /prod_config.ini ${DATADIR}/config.ini 
   	fi
fi

#check if binary if binary is available for general-system wide use
if [ -f "/usr/bin/witness_node"]
  then
    echo "Node binary found"
  else
    echo "Node binary not found.  Making binary available"
    if [ "${ENVIRONMENT}" = "test"]
      then
      	cp /tmp/testbuild/peerplays/programs/witness_node/witness_node /usr/bin/witness_node
      else
      	cp /tmp/peerplays/programs/witness_node/witness_node /usr/bin/witness_node      	
    fi 
fi

#check if wallet binary is available for general-system wide use
if [ -f "/usr/bin/cli_wallet"]
  then 
    echo "Wallet binary found"
  else
    echo "Wallet binary not found. Making binary available"
    if [ "${ENVIRONMENT}" = "test"]
      then
    	cp /tmp/testbuild/peerplays/programs/cli_wallet/cli_wallet /usr/bin/cli_wallet
      else
     	cp /tmp/peerplays/programs/cli_wallet/cli_wallet /usr/bin/cli_wallet     	
	fi
fi

if [ "${ENVIRONMENT}" = "test" ]; then	
	exec witness_node -s ${TEST_SEED} \
               --rpc-endpoint=0.0.0.0:8090 \
               -d ${DATADIR}/
fi

if [ "${ENVIRONMENT}" = "prod" ]; then
	if [ -f "${DATADIR}/genesis.json" ]
	  then
	    echo "Starting daemon in PROD"
	    exec witness_node -s ${PROD_SEED} \
		--rpc-endpoint=0.0.0.0:8090 \
		--genesis-json ${DATADIR}/genesis.json \
		-d ${DATADIR}/ 
	  else
	  	echo "Starting daemon in PROD.  Replaying blockchain"
	    cp /genesis.json ${DATADIR}
		exec witness_node -s ${PROD_SEED} \
		--replay-blockchain \
		--rpc-endpoint=0.0.0.0:8090 \
		--genesis-json ${DATADIR}/genesis.json \
		-d ${DATADIR}/ 
	fi
fi



