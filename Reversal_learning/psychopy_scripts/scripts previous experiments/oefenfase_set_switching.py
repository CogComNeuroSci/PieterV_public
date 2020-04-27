from __future__ import division
from psychopy import visual,data,event,core,gui
import time
import numpy as np
from numpy import random
import os
import math
import pandas

#define amounts of everything
Ncolors=2
Nshapes=2
Nresp=2
Nfeedback=3
Ntrials=40

#make data file
info= {"ppnr": 0, "Name":"", "Session": 0}

# Data file
already_exists = True
while already_exists:
    myDlg = gui.DlgFromDict(dictionary = info, title = "set switching task")
    directory_to_write_to = "/Users/Pieter/Documents/catastrophic forgetting/empirical/data" + "/" + str(info["ppnr"])
    if not os.path.isdir(directory_to_write_to):
        os.mkdir(directory_to_write_to)
    file_name = directory_to_write_to + "/oefenfase_set_switching_subject_" + str(info["ppnr"]) + "_Session_" + str(info["Session"]) + "_data"
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
                                                "Welkom bij dit experiment!\n\n"+
                                                "In deze taak is het de bedoeling om bepaalde stimulus-respons associaties te leren.\n\n"+
                                                "Telkens er een stimulus verschijnt is het jou taak om een knop in te drukken.\n\n"+
                                                "Als je de juiste knop indrukt verdien je een beloning\n\n"+
                                                "Druk op spatie om verder te gaan.").format(str(info["Name"])),wrapWidth=50, units="deg")
instruct        = visual.TextStim(window,text=( "De verschillende stimuli verschillen over twee dimensies:\n\n"+
                                                "kleur (groen en rood) en vorm (driehoek of vierkant).\n\n"+
                                                "Bij elke combinatie van die twee dimensies is er 1 respons die tot beloning leidt.\n\n"+
                                                "Als responsknoppen kan je kiezen tussen de 'f'-toets en 'j'-toets. \n\n"+
                                                "Te trage responsen zullen geen beloning opleveren.\n\n"+
                                                "Druk op spatie om verder te gaan."),wrapWidth=50, units="deg")
start           = visual.TextStim(window,text=( "We beginnen met een oefenfase.\n\n"+
                                                "Hier tellen je punten nog niet mee,\n\n"+
                                                "maar goed oefenen kan je natuurlijk straks wel helpen.\n\n"+
                                                "Veel succes!!\n\n"+
                                                "Als je klaar bent, \n\n"+
                                                "druk op spatie om het experiment te starten."),wrapWidth=50, units="deg")

#elements of trials
fixation=visual.TextStim(window,text=("+"))

Stimulus=visual.Polygon(win=window, radius=5, pos=(0,0),units='deg', ori=180)
shapes=['triangle', 'square']
colors=['red','green']

neg_fb=visual.TextStim(window,text=("+ 0 punten"))
pos_fb=visual.TextStim(window,text=("+ 10 punten"))
too_late=visual.TextStim(window,text=("Reageer sneller!"))
feedback=[neg_fb, pos_fb, too_late]

print('graphical_elements_ok')

#randomization
s=np.repeat(np.arange((Ncolors*Nshapes)),(math.ceil(Ntrials/(Ncolors*Nshapes))))
stim=np.random.permutation(s)
print('stim_ok')

TrialList=[]
TrialList.append({'Stimulus': stim.astype(int)})
#print(TrialList)
trials = data.TrialHandler(trialList = TrialList, nReps=1, method = "sequential")
thisExp.addLoop(trials)

#initialize data
response=0
corr=0
points=0
color=''
edge=0
accuracy=np.zeros((Ntrials))

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
    
    trials.addData("Tr", trial)
    
    #define stimulus properties
    if stim[trial]==0:
        color='red'
        edge=3
    if stim[trial]==1:
        color='green'
        edge=3    
    if stim[trial]==2:
        color='red'
        edge=4
    if stim[trial]==3:
        color='green'
        edge=4
        
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
        
    #fixation cross again and wait for response
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
    if my_clock.getTime()>1: #too late
        corr=2
    else:
        if color=='red':                         
            if edge==3:                         #red triangle = left
                if response[0]=='f':
                    corr=1                      
                else:
                    corr=0
            else:                               #red square = right
                if response[0]=='j':
                    corr=1
                else:
                    corr=0
        else:
            if edge==4:                         #green square = left
                if response[0]=='f':
                    corr=1
                else:
                    corr=0
            else:                               #green triangle = right
                if response[0]=='j':
                    corr=1
                else:
                    corr=0
    
    #keep track of points and accuracy 
    if corr==1:
        points=points+10
    
    accuracy[trial]=corr
    trials.addData("corr",corr)
    trials.addData("points",points)
    thisExp.nextEntry()
    
    #draw feedback
    feedback[corr].draw()
    window.flip()
    core.wait(1)
    
#accuracy check
check=np.mean(accuracy)

#say goodbye to the participant
goodbye         = visual.TextStim(window,text=( "Dit is het einde van de oefenfase.\n\n"+
                                                "Je hebt in totaal {} punten verdient.\n\n"+
                                                "Geef een teken aan de afnemer dat je klaar bent \n\n"+
                                                "Check voor afnemer = {}").format(str(points),str(check*100)),wrapWidth=50, units="deg",alignHoriz='center', alignVert='bottom')
goodbye.draw()
window.flip()
event.waitKeys(keyList = "space")

#save everything
thisExp.saveAsWideText(file_name, appendFile=False)
thisExp.abort()
window.close()
core.quit()   