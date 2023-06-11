#!/bin/bash -l

#SBATCH -t 48:00:00
#SBATCH -J trial-simulation
#SBATCH -o /home/mwang102/logs/trial-simulation."%j".out
#SBATCH --mem=125000
#SBATCH -p normal

source /share/sw/open/anaconda/3/bin/activate
conda activate /home/mwang102/projects/stats361-project/stats361-env
cd /home/mwang102/project/stats361-project

net_mdls=(ws_k-10_p-0.10 er_p-0.02 sb_blocks-5_wip-0.05_bwp-0.01 ba_m-5)
net_mdl=${net_mdls[${SLURM_ARRAY_TASK_ID}-1]}

for n in 100 500
do  
    python3 -m simulate_trial --data-dir 'data' --net-mdl-saved $net_mdl \
        --n $n --n-iters 500 --tau 0.0 \
        --expo-mdl-name 'one-nbr-expo' \
        --outcome-mdl-name 'additive' --delta-size 0.0 \
        --rand-mdl-name 'complete' --n-z 1000 --n-cutoff 1000 \
        --est-name 'diff-in-means'

    python3 -m simulate_trial --data-dir 'data' --net-mdl-saved $net_mdl \
        --n $n --n-iters 500 --tau 0.0 \
        --expo-mdl-name 'one-nbr-expo' \
        --outcome-mdl-name 'additive' --delta-size 0.0 \
        --rand-mdl-name 'restricted' --n-z 100000 --n-cutoff 1000 \
        --fitness-fn-name 'square-smd_frac-expo' --smd-weight 1.0 --expo-weight 1.0 \
        --est-name 'diff-in-means'

    python3 -m simulate_trial --data-dir 'data' --net-mdl-saved $net_mdl \
        --n $n --n-iters 500 --tau 0.0 \
        --expo-mdl-name 'one-nbr-expo' \
        --outcome-mdl-name 'additive' --delta-size 0.0 \
        --rand-mdl-name 'restricted-genetic' --n-z 10000 --n-cutoff 1000 \
        --fitness-fn-name 'square-smd_frac-expo' --smd-weight 1.0 --expo-weight 1.0 \
        --est-name 'diff-in-means'

    python3 -m simulate_trial --data-dir 'data' --net-mdl-saved $net_mdl \
        --n $n --n-iters 500 --tau 0.0 \
        --expo-mdl-name 'one-nbr-expo' \
        --outcome-mdl-name 'additive' --delta-size 0.0 \
        --rand-mdl-name 'graph' --n-z 1000 --n-cutoff 1000 \
        --fitness-fn-name 'square-smd_frac-expo' --smd-weight 1.0 --expo-weight 1.0 \
        --est-name 'diff-in-means'

    for tau in 0.4 0.8 
    do
        python3 -m simulate_trial --data-dir 'data' --net-mdl-saved $net_mdl \
            --n $n --n-iters 500 --tau $tau \
            --expo-mdl-name 'one-nbr-expo' 'frac-nbr-expo' --q 0.25 0.50 0.75 \
            --outcome-mdl-name 'additive' --delta-size 0.5 1.0 \
            --rand-mdl-name 'complete' --n-z 1000 --n-cutoff 1000 \
            --est-name 'diff-in-means'

        python3 -m simulate_trial --data-dir 'data' --net-mdl-saved $net_mdl \
            --n $n --n-iters 500 --tau $tau \
            --expo-mdl-name 'one-nbr-expo' 'frac-nbr-expo' --q 0.25 0.50 0.75 \
            --outcome-mdl-name 'additive' --delta-size 0.5 1.0 \
            --rand-mdl-name 'restricted' --n-z 100000 --n-cutoff 1000 \
            --fitness-fn-name 'square-smd_frac-expo' --smd-weight 1.0 --expo-weight 1.0 \
            --est-name 'diff-in-means'

        python3 -m simulate_trial --data-dir 'data' --net-mdl-saved $net_mdl \
            --n $n --n-iters 500 --tau $tau \
            --expo-mdl-name 'one-nbr-expo' 'frac-nbr-expo' --q 0.25 0.50 0.75 \
            --outcome-mdl-name 'additive' --delta-size 0.5 1.0 \
            --rand-mdl-name 'restricted-genetic' --n-z 10000 --n-cutoff 1000 \
            --fitness-fn-name 'square-smd_frac-expo' --smd-weight 1.0 --expo-weight 1.0 \
            --est-name 'diff-in-means'

        python3 -m simulate_trial --data-dir 'data' --net-mdl-saved $net_mdl \
            --n $n --n-iters 500 --tau $tau \
            --expo-mdl-name 'one-nbr-expo' 'frac-nbr-expo' --q 0.25 0.50 0.75 \
            --outcome-mdl-name 'additive' --delta-size 0.5 1.0 \
            --rand-mdl-name 'graph' --n-z 1000 --n-cutoff 1000 \
            --fitness-fn-name 'square-smd_frac-expo' --smd-weight 1.0 --expo-weight 1.0 \
            --est-name 'diff-in-means'
    done
done