column_list = ["Rule", "Stimulus", "Response", "CorResp", "FBcon", "Reward", "Expected value", "PE_estimate_low", "PE_estimate_high","Response_likelihood","Module"]
pplist=np.zeros((30))
pplist[0:8]=np.arange(3,11)
pplist[8]=12
pplist[9:31]=np.arange(14,35)
pplist = pplist.astype(int)

read_folder = "/users/pieter/Desktop/Model_study/Raw_data/Verbeke"
write_folder = "/users/pieter/Desktop/Model_study/Data_to_fit/Verbeke"

file = filename= read_folder + "Probabilistic_Reversal_task_subject_{0}_Session_0_data.tsv".format(int(p))
separation = '\t'
ids = [8, 10, 11, 13, 14]

for p in pplist:

    data = pd.read_csv(filename, sep=separation,encoding='utf-8')

    trials = np.shape(data.values)[0]

    Rule=data.values[:,ids[0]]
    Stim=data.values[:,ids[1]]
    Resp=(data.values[:,ids[2]]=='f').astype(int)

    corr = data.values[:,ids[3]]
    CorResp = np.zeros(np.size(data.values,0))
    CorResp[corr==1] =Resp[corr==1]
    CorResp[corr==0] =(Resp[corr==0]-1)*-1
    Rew=data.values[:,ids[4]]
    Rew[Rew==2]=0
    FB = (Rew == corr)*1

    new_filename= write_folder + "Data_subject_{0}.csv".format(int(p))

    new_data=pd.DataFrame({ 'Rule':Rule, 'Stimulus':Stim, 'Response':Resp, 'CorResp':CorResp, 'FBcon':FB, 'Reward':Rew, 'Expected value':np.zeros((trials)), 'PE estimate_low':np.zeros((trials)),  'PE estimate_high':np.zeros((trials)), "Response_likelihood": np.zeros((trials)), "Module":np.zeros((trials))}, columns = column_list)

    new_data.to_csv(new_filename, columns = column_list, float_format ='%.3f')
