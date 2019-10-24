#SIMULATOR_OPTS=(--limittick 1000)
SIMULATOR_OPTS=(--random-ticks 3000)

GAMMA=0.99
TOLERANCE=0.1
MAXEPOCH=1
NTICK=3000

EPSILON=0.99
NHIST=10

set -eux

if true ; then
    python3 ./lifcon_dqn_init.py --world ./lifcon.real.yaml --saveparam ./nets/dqn.0
    echo -n > replay/filelist.txt

    for iter in 1 2 3 4 5 6 7 8 9 10
    do
        prev=$((${iter} - 1))

        python3 ./lifcon_sim.py --world ./lifcon.real.yaml --replay replay/${iter}.json.gz --dqnparam nets/dqn.${prev} --epsilon ${EPSILON} --seed ${iter} ${SIMULATOR_OPTS[@]} 2>&1 | tee log/${iter}.sim.log

        echo replay/${iter}.json.gz >> replay/filelist.txt
        tail -n ${NHIST} replay/filelist.txt > replay/filelist.txt.new
        mv replay/filelist.txt.new replay/filelist.txt

        python3 ./lifcon_dqn_fit.py --world ./lifcon.real.yaml --loadparam nets/dqn.${prev} --saveparam nets/dqn.${iter} --replaylist ./replay/filelist.txt  --tolerance ${TOLERANCE} --seed ${iter} --gamma ${GAMMA} --maxnepoch ${MAXEPOCH} --double-dqn 2>&1 | tee log/${iter}.fit.log
    done
fi

EPSILON=0.8

if true ; then
    # main training: phase1, epsilon = 0.3, tolerance = 0.3, gamma = 0.9
    for iter in 11 12 13 14 15 16 17 18 19 20
    do
        prev=$((${iter} - 1))

        python3 ./lifcon_sim.py --world ./lifcon.real.yaml --replay replay/${iter}.json.gz --dqnparam nets/dqn.${prev} --epsilon ${EPSILON} --seed ${iter} ${SIMULATOR_OPTS[@]}  2>&1 | tee log/${iter}.sim.log

        echo replay/${iter}.json.gz >> replay/filelist.txt
        tail -n ${NHIST} replay/filelist.txt > replay/filelist.txt.new
        mv replay/filelist.txt.new replay/filelist.txt

        python3 ./lifcon_dqn_fit.py --world ./lifcon.real.yaml --loadparam nets/dqn.${prev} --saveparam nets/dqn.${iter}  --replaylist ./replay/filelist.txt --tolerance ${TOLERANCE} --seed ${iter} --gamma ${GAMMA} --maxnepoch ${MAXEPOCH} --double-dqn  2>&1 | tee log/${iter}.fit.log
    done
fi

EPSILON=0.6

if true ; then
    # main training: phase1, epsilon = 0.3, tolerance = 0.3, gamma = 0.9
    for iter in 21 22 23 24 25 26 27 28 29 30
    do
        prev=$((${iter} - 1))

        python3 ./lifcon_sim.py --world ./lifcon.real.yaml --replay replay/${iter}.json.gz --dqnparam nets/dqn.${prev} --epsilon ${EPSILON} --seed ${iter} ${SIMULATOR_OPTS[@]}  2>&1 | tee log/${iter}.sim.log

        echo replay/${iter}.json.gz >> replay/filelist.txt
        tail -n ${NHIST} replay/filelist.txt > replay/filelist.txt.new
        mv replay/filelist.txt.new replay/filelist.txt

        python3 ./lifcon_dqn_fit.py --world ./lifcon.real.yaml --loadparam nets/dqn.${prev} --saveparam nets/dqn.${iter}  --replaylist ./replay/filelist.txt  --tolerance ${TOLERANCE} --seed ${iter} --gamma ${GAMMA}  --maxnepoch ${MAXEPOCH} --double-dqn  2>&1 | tee log/${iter}.fit.log
    done
fi

EPSILON=0.4

if true ; then
    # main training: phase1, epsilon = 0.3, tolerance = 0.3, gamma = 0.9
    for iter in 31 32 33 34 35 36 37 38 39 40
    do
        prev=$((${iter} - 1))

        python3 ./lifcon_sim.py --world ./lifcon.real.yaml --replay replay/${iter}.json.gz --dqnparam nets/dqn.${prev} --epsilon ${EPSILON} --seed ${iter} ${SIMULATOR_OPTS[@]}  2>&1 | tee log/${iter}.sim.log

        echo replay/${iter}.json.gz >> replay/filelist.txt
        tail -n 5 replay/filelist.txt > replay/filelist.txt.new
        mv replay/filelist.txt.new replay/filelist.txt

        python3 ./lifcon_dqn_fit.py --world ./lifcon.real.yaml --loadparam nets/dqn.${prev} --saveparam nets/dqn.${iter}  --replaylist ./replay/filelist.txt  --tolerance ${TOLERANCE} --seed ${iter} --gamma ${GAMMA} --maxnepoch ${MAXEPOCH}  --double-dqn  2>&1 | tee log/${iter}.fit.log
    done
fi

EPSILON=0.2

if true ; then
    # main training: phase1, epsilon = 0.3, tolerance = 0.3, gamma = 0.9
    for iter in 41 42 43 44 45 46 47 48 49 50
    do
        prev=$((${iter} - 1))

        python3 ./lifcon_sim.py --world ./lifcon.real.yaml --replay replay/${iter}.json.gz --dqnparam nets/dqn.${prev} --epsilon ${EPSILON} --seed ${iter} ${SIMULATOR_OPTS[@]}  2>&1 | tee log/${iter}.sim.log

        echo replay/${iter}.json.gz >> replay/filelist.txt
        tail -n ${NHIST} replay/filelist.txt > replay/filelist.txt.new
        mv replay/filelist.txt.new replay/filelist.txt

        python3 ./lifcon_dqn_fit.py --world ./lifcon.real.yaml --loadparam nets/dqn.${prev} --saveparam nets/dqn.${iter}  --replaylist ./replay/filelist.txt  --tolerance ${TOLERANCE} --seed ${iter} --gamma ${GAMMA} --maxnepoch ${MAXEPOCH}  --double-dqn  2>&1 | tee log/${iter}.fit.log
    done
fi

EPSILON=0.1

if true ; then
    # main training: phase1, epsilon = 0.3, tolerance = 0.3, gamma = 0.9
    for iter in 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70
    do
        prev=$((${iter} - 1))

        python3 ./lifcon_sim.py --world ./lifcon.real.yaml --replay replay/${iter}.json.gz --dqnparam nets/dqn.${prev} --epsilon ${EPSILON} --seed ${iter} ${SIMULATOR_OPTS[@]}  2>&1 | tee log/${iter}.sim.log

        echo replay/${iter}.json.gz >> replay/filelist.txt
        tail -n ${NHIST} replay/filelist.txt > replay/filelist.txt.new
        mv replay/filelist.txt.new replay/filelist.txt

        python3 ./lifcon_dqn_fit.py --world ./lifcon.real.yaml --loadparam nets/dqn.${prev} --saveparam nets/dqn.${iter}  --replaylist ./replay/filelist.txt  --tolerance ${TOLERANCE} --seed ${iter} --gamma ${GAMMA}  --maxnepoch ${MAXEPOCH} --double-dqn  2>&1 | tee log/${iter}.fit.log
    done
fi

if true ; then
    for iter in 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129
    do
        prev=$((${iter} - 1))

        python3 ./lifcon_sim.py --world ./lifcon.real.yaml --replay replay/${iter}.json.gz --dqnparam nets/dqn.${prev} --epsilon ${EPSILON} --seed ${iter} ${SIMULATOR_OPTS[@]}  2>&1 | tee log/${iter}.sim.log

        echo replay/${iter}.json.gz >> replay/filelist.txt
        tail -n ${NHIST} replay/filelist.txt > replay/filelist.txt.new
        mv replay/filelist.txt.new replay/filelist.txt

        python3 ./lifcon_dqn_fit.py --world ./lifcon.real.yaml --loadparam nets/dqn.${prev} --saveparam nets/dqn.${iter}  --replaylist ./replay/filelist.txt  --tolerance ${TOLERANCE} --seed ${iter} --gamma ${GAMMA}  --maxnepoch ${MAXEPOCH} --double-dqn  2>&1 | tee log/${iter}.fit.log
    done
fi

EPSILON=0.01
LR=0.00002

if true ; then
    for iter in 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200
    do
        prev=$((${iter} - 1))

        python3 ./lifcon_sim.py --world ./lifcon.real.yaml --replay replay/${iter}.json.gz --dqnparam nets/dqn.${prev} --epsilon ${EPSILON} --seed ${iter} ${SIMULATOR_OPTS[@]}  2>&1 | tee log/${iter}.sim.log

        echo replay/${iter}.json.gz >> replay/filelist.txt
        tail -n ${NHIST} replay/filelist.txt > replay/filelist.txt.new
        mv replay/filelist.txt.new replay/filelist.txt

        python3 ./lifcon_dqn_fit.py --world ./lifcon.real.yaml --loadparam nets/dqn.${prev} --saveparam nets/dqn.${iter}  --replaylist ./replay/filelist.txt  --tolerance ${TOLERANCE} --seed ${iter} --gamma ${GAMMA}  --maxnepoch ${MAXEPOCH} --double-dqn  --lr ${LR} 2>&1 | tee log/${iter}.fit.log
    done
fi
