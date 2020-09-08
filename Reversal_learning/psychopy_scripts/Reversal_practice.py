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
Nparts=4
mean_switch=20
std_switch=5
Nreversals=Nparts-1
Ntrials=mean_switch*Nparts

#make data file
info= {"ppnr": 0, "Name":"", "Session": 0}

# Data file
already_exists = True
while already_exists:
    myDlg = gui.DlgFromDict(dictionary = info, title = "Probabilistic reversal learning task")
    directory_to_write_to =  "C:\Users\pp02\Desktop\Pieter\prob_reversal\Data"+ "/" + str(info["ppnr"]) #"/Users/pieter/Documents/Catastrophic forgetting/empirical"
    if not os.path.isdir(directory_to_write_to):
        os.mkdir(directory_to_write_to)
    file_name = directory_to_write_to + "/Reversal_Practice_subject_" + str(info["ppnr"]) + "_Session_" + str(info["Session"]) + "_data"
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
window=visual.Window(fullscr=True, monitor='Benq_xl2411', color=[0,0,0],colorSpace='rgb') #size=(800,600),'Benq_xl2411'
window.setMouseVisible(False)
print('window_ok')

# graphical elements
welcome         = visual.TextStim(window,text=( "Dag  {}!,\n\n"+
                                                "Nu volgt er een tweede oefenfase.\n\n"+
                                                "De taak blijft nog steeds om uit te vinden welke respons bij welke orientatie hoort.\n\n"+
                                                "Probeer zo veel mogelijk punten te sprokkelen\n\n"+
                                                "Druk op spatie om verder te gaan.").format(str(info["Name"])),wrapWidth=50, units="deg")
instruct        = visual.TextStim(window,text=( "PAS OP !!!\n\n"+
                                                "In deze fase werd er een belangrijke verandering doorgevoerd.\n\n"+
                                                "Deze keer, kunnen gedurende de taak, \n"+
                                                "de relatie tussen orientatie en respons veranderen.\n\n"+
                                                "Als je denkt dat er zo een verandering doorgevoerd is,\n"+
                                                "kan je dit aangeven door op spatie te drukken na feedback.\n\n"+
                                                "Veel succes!!\n\n"+
                                                "Als je klaar bent, druk op spatie om het experiment te starten."),wrapWidth=50, units="deg")
correct_jump      = visual.TextStim(window,text=( "Goed zo !!\n\n"+
                                                  "Er was inderdaad een verandering van regel in de laatste 10 trials\n\n"),wrapWidth=50, units="deg")
error_jump        = visual.TextStim(window,text=( "Helaas !\n\n"+
                                                  "Er was geen verandering van regel in de laatste 10 trials\n\n"),wrapWidth=50, units="deg")
copy_jump         = visual.TextStim(window,text=( "Je hebt deze verandering al eens correct aangegeven.\n\n"),wrapWidth=50, units="deg")

jump=[error_jump, correct_jump, copy_jump]
#elements of trials
fixation=visual.TextStim(window,text=("+"))

vert_grating=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=45, pos=(0,0), size= (7,7), units='deg', interpolate=False)
hor_grating=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=135, pos=(0,0), size= (7,7), units='deg', interpolate=False)
gratings=[vert_grating,hor_grating]

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
    
#randomize stimulus presentations (equal amounts per part)
stim=np.zeros(Ntrials)
while np.mean(stim)!=0.5:
    for p in range(Nparts):
        s=np.repeat(np.arange(Ngratings),(math.ceil(switch[p]/Ngratings)))
        s=np.random.permutation(s)
        if p==0:
            stim[0:int(switch_points[p])]=s[0:int(switch[p])]
        else:
           stim[int(switch_points[p-1]):int(switch_points[p])]=s[0:int(switch[p])]
print('stim_ok')

# Within-subjects design
TrialList=[]
TrialList.append( {"gratings": stim.astype(int)})
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
jump_detect=0
press=0
corr_press=0
late_press=0
early_press=0
accuracy=0
check=0

print('initialization_ok')

# welcome screen
welcome.draw()
window.flip()
event.waitKeys(keyList = "space")

instruct.draw()
window.flip()
event.waitKeys(keyList = "space") 

#trial loop   
for trial in range(Ntrials):
    
    if trial==switch_points[part]:
        part +=1
        rule =-1*rule+1
        trials_after_switch=0
        press=0
    else:
        if trial==0:
            trials_after_switch=0
        else:
            trials_after_switch +=1
    
    trials.addData("Tr", trial)
    trials.addData("part",part)
    trials.addData("rule",rule)
    trials.addData("Switch_pass",trials_after_switch)
    
    fixation.draw()
    window.flip()
    core.wait(2)
    
    event.clearEvents(eventType="keyboard")
    my_clock.reset()
    
    gratings[stim[trial].astype(int)].draw()
    window.flip()
    core.wait(.1)
        
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
        if rule==0:
            if stim[trial]==0:
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
        else:
            if stim[trial]==1:
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
    
    accuracy=accuracy+corr
    trials.addData("corr",corr)
    trials.addData("FB",fb)
    trials.addData("points",points)
    
    feedback[fb].draw()
    
    window.flip()
    core.wait(1)
    
    fixation.setColor("green")
    fixation.draw()
    window.flip()
    fixation.setColor("white")
    
    jump_detect=0
    my_clock.reset()
    jump_detect = event.waitKeys(maxWait=2, keyList = ["space"])
    if jump_detect==['space']:
        if trials_after_switch<10 and trial>10 and press==0:
            press=1
            corr_press+=1
            trials.addData("jump_detect",1)
            jump[1].draw()
            window.flip()
            core.wait(2)
        elif trials_after_switch>10:
            trials.addData("jump_detect",2)
            late_press+=1
            jump[0].draw()
            window.flip()
            core.wait(2)
        else:
            trials.addData("jump_detect",3)
            early_press+=1
            jump[2].draw()
            window.flip()
            core.wait(2)
    else:
        trials.addData("jump_detect",0)
    
    thisExp.nextEntry()
 
check=accuracy/Ntrials

#say goodbye to the participant
goodbye         = visual.TextStim(window,text=( "Dit is het einde van deze fase.\n\n"+
                                                "Je hebt in totaal {} punten verdient.\n\n"+
                                                "Geef een teken aan de afnemer dat je klaar bent \n\n"+
                                                "Check voor afnemer = {} \n"+
                                                "correct presses = {}\n"+
                                                "early presses = {}\n"+
                                                "late presses = {}\n").format(str(points), str(check), str(corr_press), str(early_press), str(late_press)),wrapWidth=50, units="deg")
goodbye.draw()
window.flip()
event.waitKeys(keyList = "space")

thisExp.saveAsWideText(file_name, appendFile=False)
thisExp.abort()
window.close()
core.quit()  