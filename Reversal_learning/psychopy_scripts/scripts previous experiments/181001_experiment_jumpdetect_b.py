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
Nparts=8  #per block
Nblocks=2
mean_switch=30
std_switch=15        #range around mean switch
Nreversals=Nparts-1
Ntrials=mean_switch*Nparts*Nblocks

#make data file
info= {"ppnr": 0, "Name":"", "Session": 0}

# Data file
already_exists = True
while already_exists:
    myDlg = gui.DlgFromDict(dictionary = info, title = "Probabilistic reversal learning task")
    directory_to_write_to = "/Users/pieter/Documents/Catastrophic forgetting/empirical" + "/" + str(info["ppnr"])
    if not os.path.isdir(directory_to_write_to):
        os.mkdir(directory_to_write_to)
    file_name = directory_to_write_to + "/Probabilistic_Reversal_task_subject_" + str(info["ppnr"]) + "_Session_" + str(info["Session"]) + "_data"
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
window=visual.Window(fullscr=True, monitor='MyLaptop', color=[0,0,0],colorSpace='rgb') #size=(800,600),
window.setMouseVisible(False)
print('window_ok')

# graphical elements
welcome         = visual.TextStim(window,text=( "Dag  {}!,\n\n"+
                                                "Nu kunnen we over gaan tot de experimentele fase\n\n"+
                                                "Vanaf nu bepalen je punten je beloning!!\n\n"+
                                                "Probeer opniew uit te vinden welke respons bij welke orientatie hoort.\n\n"+
                                                "Probeer zo veel mogelijk punten te sprokkelen\n\n"+
                                                "Druk op spatie om verder te gaan.").format(str(info["Name"])),wrapWidth=50, height=0.75, units="deg")
instruct        = visual.TextStim(window,text=( "Merk op,\n\n"+
                                                "net als vorige keer, \n"+
                                                "kunnen de relatie tussen orientatie en respons veranderen gedurende de taak.\n\n"+
                                                "Bovendien worden er in deze fase ook nieuwe orientaties gebruikt (zie hieronder).\n\n"+
                                                "Druk op spatie om verder te gaan."),wrapWidth=50,height=0.75, units="deg",pos=(0,2))
block_instruct0= visual.TextStim(window,text=("Let op !!\n\n" +
                                              "Net als in het oefenblok, \n"+
                                              "Is het voor het volgende deel de bedoeling \n"+
                                              "dat je aanduidt of er een verandering van regel is geweest. \n\n"+
                                              "Je kan dit doen als het fixatiekruis groen wordt na feedback.\n\n"+
                                              "Deze keer zal je hiervoor echter geen feedback krijgen.\n\n"+
                                              "Druk op spatie om verder te gaan."),wrapWidth=50, height=0.75, units="deg")
block_instruct1= visual.TextStim(window,text=("Let op !!\n\n" +
                                              "Voor het volgende deel is het niet meer nodig \n"
                                              "om aan te duiden als er een verandering van regel is geweest.\n\n"+
                                              "Let wel, \n"+
                                              "enkel door aandachtig te zijn voor deze veranderingen \n"+
                                              "zal je het maximum aantal punten kunnen krijgen.\n\n"+
                                              "Druk op spatie om verder te gaan."),wrapWidth=50, height=0.75, units="deg")                                              
start           = visual.TextStim(window,text=( "Denk eraan, hoe meer punten hoe meer geld!\n\n"+
                                                "En te trage responsen leveren geen punten op!\n\n"+
                                                "Veel succes!!\n\n"+
                                                "Als je klaar bent, druk op spatie om het experiment te starten."),wrapWidth=50, height=0.75, units="deg")

#elements of trials
fixation=visual.TextStim(window,text=("+"))

vert_grating=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=0, pos=(0,0), size= (5,5), units='deg', interpolate=False)
hor_grating=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=90, pos=(0,0), size= (5,5), units='deg', interpolate=False)
gratings=[vert_grating,hor_grating]

example_1=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=0, pos=(-7,-5), size= (5,5), units='deg', interpolate=False)
example_2=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=90, pos=(7,-5), size= (5,5), units='deg', interpolate=False)

neg_fb=visual.TextStim(window,text=("+ 0 punten"))
pos_fb=visual.TextStim(window,text=("+ 10 punten"))
too_late=visual.TextStim(window,text=("Reageer sneller!"))
feedback=[neg_fb, pos_fb, too_late]

print('graphical_elements_ok')

switch_points=np.zeros(Nparts*2)
switch=np.zeros(Nparts*2)

for b in range(Nblocks):
    #define points of task rule switches at random
    Ntrial_rule1=0
    Ntrial_rule2=0
    switch_block=np.zeros(Nparts)
    switch_points_block=np.zeros(Nparts)
    parts=[]

    while Ntrial_rule1!=Ntrial_rule2 or switch_block[Nreversals]<mean_switch-std_switch or switch_block[Nreversals]>mean_switch+std_switch:
        for reversals in range(Nreversals):
            switch_block[reversals]=int(random.uniform(mean_switch-std_switch,mean_switch+std_switch))
            if reversals==0:
                switch_points_block[reversals]=switch_block[reversals]    
            else:
                switch_points_block[reversals]=switch_points_block[reversals-1]+switch_block[reversals]  
        switch_points_block[Nreversals]=Ntrials/2
        switch_block[Nreversals]=Ntrials/2-np.sum(switch_block[np.arange(0,Nreversals,1)])
        Ntrial_rule1=np.sum(switch_block[np.arange(0,Nreversals+1,2)])
        Ntrial_rule2=np.sum(switch_block[np.arange(1,Nreversals+1,2)])
    if b==0:
        switch_points[0:Nreversals+1]=switch_points_block
        switch[0:Nreversals+1]=switch_block
    else:
        switch_points[Nreversals+1:Nreversals*2+2]=switch_points_block+Ntrials/2
        switch[Nreversals+1:Nreversals*2+2]=switch_block
    print('reversals_ok')
    
#randomize stimulus presentations (equal amounts per part)
stim=np.zeros(Ntrials)
while np.mean(stim)!=0.5:
    for p in range(Nparts*2):
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
if int(info['ppnr'])%4==0:
    rule=0
    block=0
elif int(info['ppnr'])%4==1:
    rule=1
    block=0
elif int(info['ppnr'])%4==2:
    rule=0
    block=1
elif int(info['ppnr'])%4==3:
    rule=1
    block=1
trials_after_switch=0
since_break=0
response=0
corr=0
fb=0
points=0
jump_detect=0
press=0

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

if block==0:
    block_instruct0.draw()
else:
    block_instruct1.draw()
window.flip()
event.waitKeys(keyList = "space") 

start.draw()
window.flip()
event.waitKeys(keyList = "space") 

#trial loop   
for trial in range(Ntrials):
    
    if trial==(Ntrials/2):
        block=-1*block+1
        since_break=0
        Break           =visual.TextStim(window,text=(  "Je kan nu even pauzeren \n\n"+
                                                        "Je hebt tot nu toe {} punten verdient.\n\n"
                                                        "Druk op spatie als je klaar bent om verder te gaan").format(str(points)),wrapWidth=50, height=0.75, units="deg")
        
        Break.draw()
        window.flip()
        event.waitKeys(keyList = "space")
        if block==0:
            block_instruct0.draw()
        else:
            block_instruct1.draw()
        window.flip()
        event.waitKeys(keyList = "space") 
    
    trials.addData("Block", block)
    
    if since_break>120 and trials_after_switch>10:
        Break           =visual.TextStim(window,text=(  "Je kan nu even pauzeren \n\n"+
                                                        "Je hebt tot nu toe {} punten verdient.\n\n"
                                                        "Druk op spatie als je klaar bent om verder te gaan").format(str(points)),wrapWidth=50, height=0.75,units="deg")
        
        Break.draw()
        window.flip()
        event.waitKeys(keyList = "space")
        since_break=0
    else:
        since_break+=1
    
    trials.addData("Break_pass", since_break)
    
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
    
    trials.addData("corr",corr)
    trials.addData("FB",fb)
    trials.addData("points",points)
    
    feedback[fb].draw()
    
    window.flip()
    core.wait(1)
    
    if block==0:
        fixation.setColor("green")
        fixation.draw()
        window.flip()
        fixation.setColor("white")
    
        jump_detect=0
        my_clock.reset()
        jump_detect = event.waitKeys(maxWait=2, keyList = ["space"])
        if jump_detect==['space']:
            fixation.draw()
            window.flip()
            core.wait(2-my_clock.getTime())
            if trials_after_switch<10 and trial>10 and press==0:
                press=1
                trials.addData("jump_detect",1)
            elif press==1:
                trials.addData("jump_detect",3)
            else:
                trials.addData("jump_detect",2)
        else:
            trials.addData("jump_detect",0)
    else:
        fixation.draw()
        window.flip()
        core.wait(2)
    
    thisExp.nextEntry()

#say goodbye to the participant
goodbye         = visual.TextStim(window,text=( "Dit is het einde van dit experiment.\n\n"+
                                                "Je hebt in totaal {} punten verdient.\n\n"+
                                                "Geef een teken aan de afnemer dat je klaar bent \n\n"+
                                                "Bedankt om deel te nemen!").format(str(points)),wrapWidth=50, height=0.75, units="deg")
goodbye.draw()
window.flip()
event.waitKeys(keyList = "space")

thisExp.saveAsWideText(file_name, appendFile=False)
thisExp.abort()
window.close()
core.quit()    