from __future__ import division
from psychopy import visual,data,event,core,gui
import time
import numpy as np
from numpy import random
import os
import math
import pandas
from collections import Counter

#define amounts of everything
Ncolors=2
Nshapes=2
Nresp=2
Nfeedback=3
Nrules=2
Nparts=8
mean_switch=50
std_switch=20        #range around mean switch
Nreversals=Nparts-1
Ntrials=mean_switch*Nparts

#make data file
info= {"ppnr": 0, "Name":"", "Session": 0}

# Data file
already_exists = True
while already_exists:
    myDlg = gui.DlgFromDict(dictionary = info, title = "set switching task")
    directory_to_write_to = "/Users/Pieter/Documents/catastrophic forgetting/empirical/data" + "/" + str(info["ppnr"])
    if not os.path.isdir(directory_to_write_to):
        os.mkdir(directory_to_write_to)
    file_name = directory_to_write_to + "/set_switching_subject_" + str(info["ppnr"]) + "_Session_" + str(info["Session"]) + "_data"
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
welcome         = visual.TextStim(window,text=( "Dag {}!,\n\n"+
                                                "Nu kunnen we over gaan tot de experimentele fase\n\n"+
                                                "Vanaf nu bepalen je punten je beloning!!\n\n"+
                                                "Probeer opniew uit te vinden welke respons bij welke stimulus hoort.\n\n"+
                                                "Gebruik opnieuw de 'f'- en 'j'-toetsen.\n\n"+
                                                "Probeer zo veel mogelijk punten te sprokkelen.\n\n"+
                                                "Druk op spatie om verder te gaan.").format(str(info["Name"])),wrapWidth=50, units="deg",alignHoriz="center")
instruct        = visual.TextStim(window,text=( "Let wel op, er worden in deze fase 2 veranderingen doorgevoerd. \n\n"+
                                                "Ten eerste gebruiken we in deze fase andere stimuli.\n\n"+
                                                "Ten tweede kan het tijdens het experiment veranderen welke stimulus bij welke respons hoort.\n\n"+
                                                "Druk op spatie om verder te gaan."),wrapWidth=50, units="deg",alignHoriz="center")
start           = visual.TextStim(window,text=( "Denk eraan, hoe meer punten hoe meer geld!\n\n"+
                                                "En te trage responsen leveren geen punten op!\n\n"+
                                                "Veel succes!!\n\n"+
                                                "Als je klaar bent, \n\n"+
                                                "druk op spatie om het experiment te starten."),wrapWidth=50, units="deg",alignHoriz="center")

#elements of trials
fixation=visual.TextStim(window,text=("+"))

Stimulus=visual.Polygon(win=window, radius=5, pos=(0,0),units='deg')
shapes=['triangle', 'square']
colors=['blue','yellow']

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
print(switch)

#randomize stimulus presentations (equal amounts per part)
stim=np.zeros(Ntrials)
c=Counter([0,0,1,2,3,4])

while c[0]!=c[1] or c[2]!=c[3] or c[0]!=c[3]: #np.mean(stim)!=1.5 
    for p in range(Nparts):
        s=np.repeat(np.arange((Ncolors*Nshapes)),(math.ceil(switch[p]/(Ncolors*Nshapes))))
        s=np.random.permutation(s)
        if p==0:
            stim[0:int(switch_points[p])]=s[0:int(switch[p])]
        else:
            stim[int(switch_points[p-1]):int(switch_points[p])]=s[0:int(switch[p])]
    c=Counter(stim.astype(int))

print('stim_ok')
print(c)

TrialList=[]
TrialList.append({'Stimulus': stim.astype(int)})
#print(TrialList)
trials = data.TrialHandler(trialList = TrialList, nReps=1, method = "sequential")
thisExp.addLoop(trials)

#initialize data
part=0
set=int(info['ppnr'])%2
trials_after_switch=0
since_break=0
response=0
corr=0
points=0
color=''
edge=0

print('initialization_ok')

# welcome screen
welcome.draw()
window.flip()
event.waitKeys(keyList = "space")

instruct.draw()
window.flip()
event.waitKeys(keyList = "space") 

start.draw()
window.flip()
event.waitKeys(keyList = "space") 

#trial loop   
for trial in range(Ntrials):
    #break
    if since_break>100 and trials_after_switch>30:
        Break           =visual.TextStim(window,text=(  "Je kan nu even pauzeren \n\n"+
                                                "Je hebt tot nu toe {} punten verdient.\n\n"
                                                "Druk op spatie als je klaar bent om verder te gaan").format(str(points)),wrapWidth=50, units="deg",alignHoriz="center")
        
        Break.draw()
        window.flip()
        event.waitKeys(keyList = "space")
        since_break=0
    else:
        since_break+=1
    
    trials.addData("Break_pass", since_break)
    
    #switch
    if trial==switch_points[part]:
        part +=1
        set=-1*set+1
        trials_after_switch=0
    else:
        if trial==0:
            trials_after_switch=0
        else:
            trials_after_switch +=1
    
    trials.addData("Tr", trial)
    trials.addData("part",part)
    trials.addData("Set",set)
    trials.addData("Switch_pass",trials_after_switch)
    
    #define stimulus properties
    if stim[trial]==0:
        color='yellow'
        edge=3
        Stimulus.ori=0
    if stim[trial]==1:
        color='blue'
        edge=3    
        Stimulus.ori=0
    if stim[trial]==2:
        color='yellow'
        edge=4
        Stimulus.ori=45
    if stim[trial]==3:
        color='blue'
        edge=4
        Stimulus.ori=45
        
    #set stimulus properties
    Stimulus.lineColor=color
    Stimulus.fillColor=color
    Stimulus.edges=edge
    
    #fixation cross
    fixation.draw()
    window.flip()
    core.wait(2)
    
    #reset everything for response recording
    event.clearEvents(eventType="keyboard")
    my_clock.reset()
    
    #draw stimulus for 200 ms
    while my_clock.getTime()<.2:
        Stimulus.draw()
        window.flip()
        
    #fixation cross and wait for response
    fixation.draw()
    window.flip()
    
    response = event.waitKeys(keyList = ["f","j","escape"])
    
    #add data
    trials.addData("Color", color)
    trials.addData("Shape", shapes[edge-3])
    trials.addData("Resp",response[0])
    trials.addData("RT", my_clock.getTime())
    
    #escape option
    if response[0]=="escape":
        thisExp.saveAsWideText(file_name, appendFile=False)
        thisExp.abort()
        core.quit()
        
    #define correct
    if my_clock.getTime()>1:                               #too late
        corr=2
    else:
        if set==0:                                         #set 1
            if color=='yellow':
                if edge==3:                                #yellow triangle = left
                    if response[0]=='f':
                        corr=1
                    else:
                        corr=0
                else:                                      #yellow square = right
                    if response[0]=='j':
                        corr=1
                    else:
                        corr=0
            else:
                if edge==4:                                #blue square = left
                    if response[0]=='f':
                        corr=1
                    else:
                        corr=0
                else:                                      #blue triangle = right
                    if response[0]=='j':
                        corr=1
                    else:
                        corr=0
        else:                                              #set 2
            if color=='yellow':
                if edge==3:                                #yellow triangle = right
                    if response[0]=='j':
                        corr=1
                    else:
                        corr=0
                else:                                      #yellow square = left
                    if response[0]=='f':
                        corr=1
                    else:
                        corr=0
            else:
                if edge==4:                                #blue square = right
                    if response[0]=='j':
                        corr=1
                    else:
                        corr=0
                else:                                      #blue triangle = left
                    if response[0]=='f':
                        corr=1
                    else:
                        corr=0
                        
    #points
    if corr==1:
        points=points+10
    
    trials.addData("corr",corr)
    trials.addData("points",points)
    thisExp.nextEntry()
    
    #feedback
    feedback[corr].draw()
    window.flip()
    core.wait(1)

#say goodbye to the participant
goodbye         = visual.TextStim(window,text=( "Dit is het einde van dit experiment.\n\n"+
                                                "Je hebt in totaal {} punten verdient.\n\n"+
                                                "Geef een teken aan de afnemer dat je klaar bent. \n\n"+
                                                "Bedankt om deel te nemen!").format(str(points)),wrapWidth=50, units="deg", alignHoriz="center")
goodbye.draw()
window.flip()
event.waitKeys(keyList = "space")

thisExp.saveAsWideText(file_name, appendFile=False)
thisExp.abort()
window.close()
core.quit()    