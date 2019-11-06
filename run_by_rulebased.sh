SIMULATOR_OPTS_0=(--starttick 0 --limittick  3000)
SIMULATOR_OPTS_1=(--starttick 10800 --limittick 3000)
SIMULATOR_OPTS_2=(--starttick 46800 --limittick 3000)
SIMULATOR_OPTS_3=(--starttick 18000 --limittick 3000)

if true ; then
  iter=test2
  python3 ./lifcon_sim.py --world ./lifcon.real.yaml --replay replay/${iter}0.json.gz ${SIMULATOR_OPTS_0[@]} 2>&1 | tee log/${iter}0.sim.log
  python3 ./lifcon_sim.py --world ./lifcon.real.yaml --replay replay/${iter}1.json.gz ${SIMULATOR_OPTS_1[@]} 2>&1 | tee log/${iter}1.sim.log
  python3 ./lifcon_sim.py --world ./lifcon.real.yaml --replay replay/${iter}2.json.gz ${SIMULATOR_OPTS_2[@]} 2>&1 | tee log/${iter}2.sim.log
  python3 ./lifcon_sim.py --world ./lifcon.real.yaml --replay replay/${iter}3.json.gz ${SIMULATOR_OPTS_3[@]} 2>&1 | tee log/${iter}3.sim.log
fi