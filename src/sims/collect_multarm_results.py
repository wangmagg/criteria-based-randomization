import pickle
from pathlib import Path
import pandas as pd
import argparse

from src.sims.trial import *
from src.sims.run_multarm_trial import *

def se_handle_none(x):
    x_no_none = [el for el in x if el is not None]
    if len(x_no_none) == 0:
        return None
    return np.std(x.to_numpy()) / np.sqrt(len(x))



if __name__ == "__main__":
    """
    Collect results from simulated multi-arm trials across different configurations
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('--output-dir', type=str, default='output')
    parser.add_argument('--exp-subdir', type=str, default='mult-arm')
    parser.add_argument('--res-dir', type=str, default='res')
    args = parser.parse_args()

    res_dir = Path(args.output_dir) / args.exp_subdir
    all_trial_res = []

    for n_arm_subdir in res_dir.glob('arms-*'):
        print(n_arm_subdir)
        for n_per_arm_subdir in n_arm_subdir.glob('n-per-arm-*'):
            print(n_per_arm_subdir)
            for n_z_subdir in n_per_arm_subdir.glob('n-z-*'):
                print(n_z_subdir)
                for rand_mdl_subdir in n_z_subdir.glob('rand-*'):
                    print(rand_mdl_subdir)

                    for trial_fname in rand_mdl_subdir.glob('*.pkl'):
                        with open(trial_fname, 'rb') as f:
                            trial = pickle.load(f)
                        
                        trial.loader = SimulatedTrialLoader(trial.config)
                        trial.mapping, trial.use_cols = None, None
                        trial.set_data_from_config()

                        data_rep = trial_fname.stem
                        arms = n_arm_subdir.name.split('-')[-1]
                        n_per_arm = n_per_arm_subdir.name.split('-')[-1]
                        n_z = n_z_subdir.name.split('-')[-1]

                        smd = SumMaxSMD(trial.X)
                        smd_scores = smd(trial.z_pool)
                        mean_smd = np.mean(smd_scores)
                        sd_smd = np.std(smd_scores)
                        max_smd = np.max(smd_scores)
                        min_smd = np.min(smd_scores)
                        
                        trial_res = {'data_rep': data_rep,
                                    'rand_mdl': rand_mdl_subdir.name,
                                    'arms': arms,
                                    'n_per_arm': n_per_arm,
                                    'n_z': n_z,
                                    'mean_smd': mean_smd,
                                    'sd_smd': sd_smd,
                                    'max_smd': max_smd,
                                    'min_smd': min_smd,
                                    'tau_true': trial.tau_true, 
                                    'bias': trial.bias, 
                                    'rmse': trial.rmse, 
                                    'rr': trial.rr}
                        
                        all_trial_res.append(trial_res)

    all_trial_res = pd.DataFrame.from_records(all_trial_res)
    all_trial_res_agg = all_trial_res.groupby(['rand_mdl', 'arms', 'n_per_arm', 'n_z']).agg(
        mean_mean_smd = ('mean_smd', 'mean'),
        se_mean_smd = ('mean_smd', lambda x: np.std(x.to_numpy()) / np.sqrt(len(x))),
        mean_sd_smd = ('sd_smd', 'mean'),
        se_sd_smd = ('sd_smd', lambda x: np.std(x.to_numpy()) / np.sqrt(len(x))),
        mean_max_smd = ('max_smd', 'mean'),
        se_max_smd = ('max_smd', lambda x: np.std(x.to_numpy()) / np.sqrt(len(x))),
        mean_min_smd = ('min_smd', 'mean'),
        se_min_smd = ('min_smd', lambda x: np.std(x.to_numpy()) / np.sqrt(len(x))),
        mean_tau_true = ('tau_true', 'mean'),
        se_tau_true = ('tau_true', lambda x: se_handle_none(x)),
        mean_bias = ('bias', 'mean'),
        se_bias = ('bias', lambda x: se_handle_none(x)),
        mean_rmse = ('rmse', 'mean'),
        se_rmse = ('rmse', lambda x: se_handle_none(x)),
        mean_rr = ('rr', 'mean'),
        se_rr = ('rr', lambda x: se_handle_none(x))).reset_index()
        
    res_dir = Path(args.res_dir) / args.exp_subdir
    if not res_dir.exists():
        res_dir.mkdir(parents=True)

    all_trial_res.to_csv(res_dir / f'{args.exp_subdir}_results.csv', index=False)
    all_trial_res_agg.to_csv(res_dir / f'{args.exp_subdir}_results_rep-agg.csv', index=False)