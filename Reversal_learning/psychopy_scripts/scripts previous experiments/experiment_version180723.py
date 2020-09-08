from __future__ import division
from psychopy import visual,data,event,core,gui
import time
import numpy as np
from numpy import random
import os
import math
import pandas

#define amounts of everything
Ngratings=2
Nresp=2
Nfeedback=2
Nrules=2
Nparts=2
mean_switch=6
std_switch=0        #range around mean switch
Nreversals=Nparts-1
Ntrials=mean_switch*Nparts*Nrules

#make data file
info= {"ppnr": 0, "Name":"", "Session": 0}

# Data file
already_exists = True
while already_exists:
    myDlg = gui.DlgFromDict(dictionary = info, title = "experiment_model")
    directory_to_write_to = "/Users/Pieter/Documents/catastrophic forgetting/empirical/data" + "/" + str(info["ppnr"]) # Voer hier ipv mijn directory jouw directory in!!
    if not os.path.isdir(directory_to_write_to):
        os.mkdir(directory_to_write_to)
    file_name = directory_to_write_to + "/experiment_model_" + str(info["ppnr"]) + "_Session_" + str(info["Session"]) + "_data"
    if not os.path.isfile(file_name+".tsv"):
        already_exists = False
    else:
        myDlg2 = gui.Dlg(title = "Error")
        myDlg2.addText("Try another participant number")
        myDlg2.show()
print("OK, let's get started!")

thisExp = data.ExperimentHandler(dataFileName = file_name, extraInfo = info)
my_clock= core.Clock()
#make window
window=visual.Window(fullscr=True, monitor='testMonitor', color=[0,0,0],colorSpace='rgb') #size=(800,600),
window.setMouseVisible(False)
print('window_ok')

# graphical elements
welcome         = visual.TextStim(window,text=( "Opnieuw welkom {}!,\n\n"+
                                                "Nu kunnen we over gaan tot de experimentele fase\n\n"+
                                                "Vanaf nu bepalen je punten je beloning!!\n\n"+
                                                "Probeer opniew uit te vinden welke respons bij welke orientatie hoort.\n\n"+
                                                "Probeer zo veel mogelijk punten te sprokkelen\n\n"+
                                                "Druk op spatie om verder te gaan.").format(str(info["Name"])),wrapWidth=50, units="deg")
instruct        = visual.TextStim(window,text=( "PAS OP !!!\n\n"+
                                                "Er worden in deze fase enkele veranderingen doorgevoerd.\n\n"+
                                                "Ten eerste zijn er nieuwe stimul (zie hieronder)\n\n"+
                                                "Ten tweede, kunnen de relatie tussen respons en stimuli nu voortdurend veranderen.\n\n"+
                                                "Druk op spatie om verder te gaan."),wrapWidth=50, units="deg",pos=(0,5))
start           = visual.TextStim(window,text=( "Denk eraan, hoe meer punten hoe meer geld!\n\n"+
                                                "En te trage responsen leveren geen punten op!\n\n"+
                                                "Veel succes!!\n\n"+
                                                "Als je klaar bent, druk op spatie om het experiment te starten."),wrapWidth=50, units="deg")

#elements of trials
fixation=visual.TextStim(window,text=("+"))

vert_grating=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=0, pos=(0,0), size= (7,7), units='deg', interpolate=False)
hor_grating=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=90, pos=(0,0), size= (7,7), units='deg', interpolate=False)
gratings=[vert_grating,hor_grating]

example_1=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=0, pos=(-10,-7), size= (7,7), units='deg', interpolate=False)
example_2=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=90, pos=(10,-7), size= (7,7), units='deg', interpolate=False)

neg_fb=visual.TextStim(window,text=("+ 0 punten"))
pos_fb=visual.TextStim(window,text=("+ 10 punten"))
too_late=visual.TextStim(window,text=("Reageer sneller!"))
feedback=[neg_fb, pos_fb, too_late]

print('graphical_elements_ok')

#define points of task rule switches at random
Ntrial_rule1_ver=0
Ntrial_rule2_ver=0
Ntrial_rule1_hor=0
Ntrial_rule2_hor=0
sum_tr=0
switch_ver=np.zeros(Nparts)
switch_hor=np.zeros(Nparts)
parts=[]

while Ntrial_rule1_hor!=Ntrial_rule2_hor or Ntrial_rule1_ver!=Ntrial_rule2_ver or sum_tr!=Ntrials:
    for reversals in range(Nreversals):
        switch_ver[reversals]=int(random.uniform(mean_switch-std_switch,mean_switch+std_switch))
        switch_hor[reversals]=int(random.uniform(mean_switch-std_switch,mean_switch+std_switch))
    switch_ver[Nreversals]=Ntrials/2-np.sum(switch_ver[np.arange(0,Nreversals,1)])
    switch_hor[Nreversals]=Ntrials/2-np.sum(switch_hor[np.arange(0,Nreversals,1)])
    Ntrial_rule1_ver=np.sum(switch_ver[np.arange(0,Nreversals+1,2)])
    Ntrial_rule2_ver=np.sum(switch_ver[np.arange(1,Nreversals+1,2)])
    Ntrial_rule1_hor=np.sum(switch_ver[np.arange(0,Nreversals+1,2)])
    Ntrial_rule2_hor=np.sum(switch_ver[np.arange(1,Nreversals+1,2)])
    sum_tr=Ntrial_rule1_ver+Ntrial_rule2_ver+ Ntrial_rule1_hor+Ntrial_rule2_hor
    
print('reversals_ok')
print(switch_ver)
print(switch_hor)

#randomize stimulus presentations (equal amounts per part)
s=np.repeat(np.arange(Ngratings),(math.ceil(Ntrials/Ngratings)))
stim=np.random.permutation(s)

print('stim_ok')

# Within-subjects design
TrialList=[]
TrialList.append( {"gratings": stim.astype(int)})
print(TrialList)
trials = data.TrialHandler(trialList = TrialList, nReps=1, method = "sequential")
thisExp.addLoop(trials)

#initialize data
hor=0
ver=0
part_hor=0
part_ver=0
rule_hor=int(info['ppnr'])%2
rule_ver=(int(info['ppnr'])%2)*-1+1
since_break=0
response=0
corr=0
fb=0
points=0

print('initialization_ok')

# welcome screen
welcome.draw()
window.flip()
event.waitKeys(keyList = "space")

instruct.draw()
example_1.draw()
example_2.draw()
window.flip()
event.waitKeys(keyList = "space") 

start.draw()
window.flip()
event.waitKeys(keyList = "space") 

#trial loop   
for trial in range(Ntrials):
    
    if since_break>100 and ver>5 and hor>5:
        Break           =visual.TextStim(window,text=(  "Je kan nu even pauzeren \n\n"+
                                                "Je hebt tot nu toe {} punten verdient.\n\n"
                                                "Druk op spatie als je klaar bent om verder te gaan").format(str(points)),wrapWidth=50, units="deg")
        
        Break.draw()
        window.flip()
        event.waitKeys(keyList = "space")
        since_break=0
    else:
        since_break+=1
    
    trials.addData("Break_pass", since_break)
    
    if stim[trial]==0:
        ver +=1
    else:
        hor +=1
    
    if ver== switch_ver[part_ver]:
        ver = 0
        rule_ver= -1*rule_ver+1
        part_ver +=1
        
    if hor== switch_hor[part_hor]:
        hor = 0
        rule_hor= -1*rule_hor+1
        part_hor +=1
    
    trials.addData("Tr", trial)
    trials.addData("part_ver",part_ver)
    trials.addData("part_hor",part_hor)
    trials.addData("rule_ver",rule_ver)
    trials.addData("rule_hor",rule_hor)
    trials.addData("Switch_pass_ver",ver)
    trials.addData("Switch_pass_hor",hor)
    
    fixation.draw()
    window.flip()
    core.wait(1)
    
    event.clearEvents(eventType="keyboard")
    my_clock.reset()
    while my_clock.getTime()<.1:
        gratings[stim[trial].astype(int)].draw()
        window.flip()
        
    fixation.draw()
    window.flip()
    
    response = event.waitKeys(keyList = ["f","j","escape"])
    
    if response[0]=="escape":
        thisExp.saveAsWideText(file_name, appendFile=False)
        thisExp.abort()
        core.quit()
        
    trials.addData("Grating", stim[trial])
    trials.addData("Resp",response[0])
    trials.addData("RT", my_clock.getTime())
    
    if my_clock.getTime()>1:
        fb=2
    else:
        if stim[trial]==0:
            if rule_ver==0:
                if response[0]=="f":                        #left
                    corr=1                                  #correct
                else:                                       #right
                    corr=0
            else:
                if response[0]=="j":                        #right
                    corr=1                                  #correct
                else:                                       #right
                    corr=0
        else:
            if rule_hor==0:
                if response[0]=="f":                        #left
                    corr=1                                  #correct
                else:                                       #right
                    corr=0
            else:
                if response[0]=="j":                        #right
                    corr=1                                  #correct
                else:                                       #right
                    corr=0
        fb=corr
    if fb==1:
        points=points+10
    
    trials.addData("corr",corr)
    trials.addData("FB",fb)
    trials.addData("points",points)
    thisExp.nextEntry()
    
    feedback[fb].draw()
    
    window.flip()
    core.wait(1)

#say goodbye to the participant
goodbye         = visual.TextStim(window,text=( "Dit is het einde van dit experiment.\n\n"+
                                                "Je hebt in totaal {} punten verdient.\n\n"+
                                                "Geef een teken aan de afnemer dat je klaar bent \n\n"+
                                                "Bedankt om deel te nemen!").format(str(points)),wrapWidth=50, units="deg")
goodbye.draw()
window.flip()
event.waitKeys(keyList = "space")

thisExp.saveAsWideText(file_name, appendFile=False)
thisExp.abort()
window.close()
core.quit()    