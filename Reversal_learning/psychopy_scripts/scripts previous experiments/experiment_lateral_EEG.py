# -*- coding: utf-8 -*-
from __future__ import division
from psychopy import visual,data,event,core,gui,parallel
import time
import numpy as np
from numpy import random
import os
import math
import pandas

send_eegtriggers = True
trigger_on_time = .03
﻿if send_eegtriggers:
    # Address for the parallel port in the biosemi setup
    parallel.setPortAddress(0xC020)
    # this sends the trigger, usually initialize it at zero
    # then the trigger, then a wait-function for e.g. 30 ms, and zero again
    parallel.setData(0)
    time.sleep(trigger_on_time)

    # trigger of beginning of the experiment
    parallel.setData(int(np.binary_repr(1, 8), 2))
    time.sleep(trigger_on_time)
    parallel.setData(int(np.binary_repr(0, 8), 2))

#define amounts of everything
Ngratings=2
Nresp=2
Nfeedback=2
Nrules=2
Nparts=10
mean_switch=40
std_switch=20        #range around mean switch
Nreversals=Nparts-1
Ntrials=mean_switch*Nparts

#make data file
info= {"ppnr": 0, "Name":"", "Session": 0}

# Data file
already_exists = True
while already_exists:
    myDlg = gui.DlgFromDict(dictionary = info, title = "Probabilistic reversal learning task")
    directory_to_write_to = "/Users/Pieter/Documents/psychopy_exercices" + "/" + str(info["ppnr"])
    if not os.path.isdir(directory_to_write_to):
        os.mkdir(directory_to_write_to)
    file_name = directory_to_write_to + "/Prob_reversal_learning_task_subject_" + str(info["ppnr"]) + "_Session_" + str(info["Session"]) + "_data"
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

print('window_ok')

# graphical elements
welcome         = visual.TextStim(window,text=( "hello again {}!,\n\n"+
                                                "Nu kunnen we over gaan tot de experimentele fase\n\n"+
                                                "Vanaf nu bepalen je punten je beloning!!\n\n"+
                                                "Probeer opniew uit te vinden welke  welke orientatie meest punten oplevert.\n\n"+
                                                "Probeer zo veel mogelijk punten te sprokkelen\n\n"+
                                                "Druk op spatie om verder te gaan.").format(str(info["Name"])),wrapWidth=50, units="deg")
instruct        = visual.TextStim(window,text=( "PAS OP !!!\n\n"+
                                                "Er worden in deze fase enkele veranderingen doorgevoerd.\n\n"+
                                                "Ten eerste zijn er nieuwe stimul (zie hieronder)\n\n"+
                                                "Ten tweede, kan er nu voortdurend veranderen welke orientatie meest punten oplevert.\n\n"+
                                                "Druk op spatie om verder te gaan."),wrapWidth=50, units="deg",pos=(0,5))
start           = visual.TextStim(window,text=( "Denk eraan, hoe meer punten hoe meer geld!\n\n"+
                                                "En te trage responsen leveren geen punten op!\n\n"+
                                                "Veel succes!!\n\n"+
                                                "Als je klaar bent, druk op spatie om het experiment te starten."),wrapWidth=50, units="deg")

#elements of trials
fixation=visual.TextStim(window,text=("+"))

vert_grating=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=0, size= (7,7), units='deg', interpolate=False)
hor_grating=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=90, size= (7,7), units='deg', interpolate=False)
gratings=[vert_grating,hor_grating]

example_1=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=0, pos=(-5,-7), size= (7,7), units='deg', interpolate=False)
example_2=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=90, pos=(5,-7), size= (7,7), units='deg', interpolate=False)

neg_fb=visual.TextStim(window,text=("+ 0 punten"))
pos_fb=visual.TextStim(window,text=("+ 10 punten"))
too_late=visual.TextStim(window,text=("Reageer sneller!"))
feedback=[neg_fb, pos_fb, too_late]

print('graphical_elements_ok')

#define points of task rule switches at random
Ntrial_rule1=0
Ntrial_rule2=0
switch=np.zeros(Nparts)
switch_points=np.zeros(Nparts)
parts=[]

while Ntrial_rule1!=Ntrial_rule2 or switch[Nreversals]<mean_switch-std_switch or switch[Nreversals]>mean_switch+std_switch:
    for reversals in range(Nreversals):
        switch[reversals]=int(random.uniform(mean_switch-std_switch,mean_switch+std_switch))
        if reversals==0:
            switch_points[reversals]=switch[reversals]    
        else:
            switch_points[reversals]=switch_points[reversals-1]+switch[reversals]  
    switch_points[Nreversals]=Ntrials
    switch[Nreversals]=Ntrials-np.sum(switch[np.arange(0,Nreversals,1)])
    Ntrial_rule1=np.sum(switch[np.arange(0,Nreversals+1,2)])
    Ntrial_rule2=np.sum(switch[np.arange(1,Nreversals+1,2)])
print('reversals_ok')

#randomize stimulus presentation sides (equal amounts per part)
positions=np.zeros(Ntrials)
while np.mean(positions)!=0.5:
    for p in range(Nparts):
        s=np.repeat(np.arange(Ngratings),(math.ceil(switch[p]/Ngratings)))
        s=np.random.permutation(s)
        if p==0:
            positions[0:int(switch_points[p])]=s[0:int(switch[p])]
        else:
            positions[int(switch_points[p-1]):int(switch_points[p])]=s[0:int(switch[p])]

print('positions_ok')

# Within-subjects design
TrialList=[]
TrialList.append( {"positions": positions.astype(int)})
print(TrialList)
trials = data.TrialHandler(trialList = TrialList, nReps=1, method = "sequential")
thisExp.addLoop(trials)

#initialize data
part=0
rule=int(info['ppnr'])%2
trials_after_switch=0
since_break=0
response=0
corr=0
fb=0
points=0
dist_to_center=5

print('initialization_ok')

# welcome screen
welcome.draw()
window.flip()
event.waitKeys(keyList = "space")

instruct.draw()
fixation.pos=(0,-7)
fixation.draw()
example_1.draw()
example_2.draw()
window.flip()
event.waitKeys(keyList = "space") 

fixation.pos=(0,0)

start.draw()
window.flip()
event.waitKeys(keyList = "space") 

#trial loop   
for trial in range(Ntrials):
    
    if since_break>100 and trials_after_switch>15:
        Break           =visual.TextStim(window,text=(  "Je kan nu even pauzeren \n\n"+
                                                "Je hebt tot nu toe {} punten verdient.\n\n"
                                                "Druk op spatie als je klaar bent om verder te gaan").format(str(points)),wrapWidth=50, units="deg")
        
        Break.draw()
        window.flip()
        event.waitKeys(keyList = "space")
        since_break=0
        #signal break
        ﻿if send_eegtriggers:
            parallel.setData(int(np.binary_repr(99, 8), 2))
            time.sleep(trigger_on_time)
            parallel.setData(int(np.binary_repr(0, 8), 2))
    else:
        since_break+=1
    
    trials.addData("Break_pass", since_break)
    
    if trial==switch_points[part]:
        part +=1
        rule =-1*rule+1
        trials_after_switch=0
    else:
        if trial==0:
            trials_after_switch=0
        else:
            trials_after_switch +=1
    
    trials.addData("Tr", trial)
    trials.addData("part",part)
    trials.addData("rule",rule)
    trials.addData("Switch_pass",trials_after_switch)
    
    if positions[trial]==0:
        gratings[0].pos=(dist_to_center,0) #position 1: vertical grating right, horizontal left
        gratings[1].pos=(-dist_to_center,0) 
    else:
        gratings[0].pos=(-dist_to_center,0) #position 2: vertical grating left, horizontal right
        gratings[1].pos=(dist_to_center,0)
    
    fixation.draw()
    window.flip()
    
    if send_eegtriggers:
        parallel.setData(int(np.binary_repr(10, 8), 2))
        time.sleep(trigger_on_time)
        parallel.setData(int(np.binary_repr(0, 8), 2))
        
    core.wait(2)
    
    event.clearEvents(eventType="keyboard")
    my_clock.reset()
    while my_clock.getTime()<.2:
        fixation.draw()
        gratings[0].draw()
        gratings[1].draw()
        window.flip()
        
    fixation.draw()
    window.flip()
    
    if send_eegtriggers:
        parallel.setData(int(np.binary_repr(20+positions[trial], 8), 2))
        time.sleep(trigger_on_time)
        parallel.setData(int(np.binary_repr(0, 8), 2))
    
    response = event.waitKeys(keyList = ["f","j","escape"])
    
    trials.addData("RT", my_clock.getTime())
    
    if send_eegtriggers:
        parallel.setData(int(np.binary_repr(30, 8), 2))
        time.sleep(trigger_on_time)
        parallel.setData(int(np.binary_repr(0, 8), 2))
        
    trials.addData("positions", positions[trial])
    trials.addData("Resp",response[0])
    
    if response[0]=="escape":
        thisExp.saveAsWideText(file_name, appendFile=False)
        thisExp.abort()
        core.quit()
    
    if my_clock.getTime()>1:
        fb=2
    else:
        if rule==0:                                         #rule 1: vertical wrong horizontal correct
            if positions[trial]==0:                         #vertical right and horizontal left
                if response[0]=="f":                        #left (horizontal)
                    corr=1                                  #correct
                    if np.random.random()>=0.8:
                        fb=0                                #no reward
                    else:
                        fb=1                                #reward
                else:                                       #right (vertical)
                    corr=0                                  #wrong
                    if np.random.random()>=0.2:
                        fb=0                                #no reward
                    else:
                        fb=1                                #reward
            else:                                           #vertical left and horizontal right
                if response[0]=="j":                        #right (horizontal)
                    corr=1                                  #correct
                    if np.random.random()>=0.8:
                        fb=0                                #no reward
                    else:
                        fb=1                                #reward
                else:                                       #left (vertical)
                    corr=0
                    if np.random.random()>=0.2:
                        fb=0                                #no reward
                    else:
                        fb=1                                #reward
        else:
            if positions[trial]==1:
                if response[0]=="f":                        #left
                    corr=1                                  #correct
                    if np.random.random()>=0.8:
                        fb=0                                #no reward
                    else:
                        fb=1                                #reward
                else:                                       #right
                    corr=0
                    if np.random.random()>=0.2:
                        fb=0                                #no reward
                    else:
                        fb=1                                #reward
            else:
                if response[0]=="j":                        #right
                    corr=1                                  #correct
                    if np.random.random()>=0.8:
                        fb=0                                #no reward
                    else:
                        fb=1                                #reward
                else:                                       #right
                    corr=0
                    if np.random.random()>=0.2:
                        fb=0                                #no reward
                    else:
                        fb=1                                #reward
    if fb==1:
        points=points+10
    
    trials.addData("corr",corr)
    trials.addData("FB",fb)
    trials.addData("points",points)
    thisExp.nextEntry()
    
    feedback[fb].draw()
    
    window.flip()
    
    if send_eegtriggers:
        parallel.setData(int(np.binary_repr(40+(fb*2+corr), 8), 2))
        time.sleep(trigger_on_time)
        parallel.setData(int(np.binary_repr(0, 8), 2))
        
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