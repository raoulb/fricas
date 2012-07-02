printf "SPADLIST_xgraph="
cat xgraph.spad.pamphlet|grep '^<<\(category\|domain\|package\)'|awk '{printf "\\\n    " $2 }'
echo

printf "CATLIST_xgraph="
cat xgraph.spad.pamphlet|grep '^<<\(category\)'|awk '{printf "\\\n    " $2 }'
echo
echo CATDOMS_xgraph=FGRAPH
echo '##end xgraph'