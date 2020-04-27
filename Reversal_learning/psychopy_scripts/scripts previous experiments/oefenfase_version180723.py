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
Ntrials=30

#Initialize data
response=0
corr=0
fb=0
points=0

print('initialization_ok')

#make data file
info= {"ppnr": 0, "Name":"", "Session": 0}

# Data file
already_exists = True
while already_exists:
    myDlg = gui.DlgFromDict(dictionary = info, title = "Probabilistic reversal learning task")
    directory_to_write_to = "/Users/Pieter/Documents/psychopy_exercices" + "/" + str(info["ppnr"]) # Voer hier jouw directory in ipv de mijne
    if not os.path.isdir(directory_to_write_to):
        os.mkdir(directory_to_write_to)
    file_name = directory_to_write_to + "/Prob_reversal_learning_task_subject_" + str(info["ppnr"]) + "_Session_" + str(info["Session"]) + "_oefdata"
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
                                                "In deze taak moet je reageren op de orientatie van een stimulus. \n"+
                                                "Probeer uit te vinden welke respons bij welke orientatie hoort.\n\n"+
                                                "Probeer zo veel mogelijk punten te sprokkelen\n\n"+
                                                "Druk op spatie om verder te gaan.").format(str(info["Name"])),wrapWidth=50, units="deg",alignHoriz='center', alignVert='bottom')
instruct        = visual.TextStim(window,text=( "Hieronder zie je een voorbeeld van de stimuli.\n\n"
                                                "Als een van deze stimuli verschijnt,\n"+
                                                "Druk dan zo snel mogelijk links (letter 'f') of rechts (letter 'j').\n\n"+
                                                "Te trage responsen leveren geen punten op!\n\n"+
                                                "Druk op spatie om om verder te gaan."),wrapWidth=50, units="deg",alignHoriz='center', alignVert='bottom')
start           =visual.TextStim(window,text=("We starten met een oefenfase.\n\n"+
                                              "Hier tellen je punten nog niet mee.\n\n"+
                                              "Maar goed oefenen kan je natuurlijk helpen straks meer te verdienen.\n\n"+
                                              "Als je klaar bent, druk op spatie om het experiment te starten."),wrapWidth=50, units="deg",alignHoriz='center', alignVert='bottom')


#elements of trials
fixation = visual.TextStim(window,text=("+"))

vert_grating=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=45, pos=(0,0), size= (7,7), units='deg', interpolate=False)
hor_grating=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=135, pos=(0,0), size= (7,7), units='deg', interpolate=False)
gratings=[vert_grating,hor_grating]

example_1=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=45, pos=(-10,-7), size= (7,7), units='deg', interpolate=False)
example_2=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=135, pos=(10,-7), size= (7,7), units='deg', interpolate=False)

neg_fb=visual.TextStim(window,text=("+ 0 punten"))
pos_fb=visual.TextStim(window,text=("+ 10 punten"))
too_late=visual.TextStim(window,text=("Reageer sneller!"))
feedback=[neg_fb, pos_fb, too_late]

print('graphical_elements_ok')

#randomize stimulus presentations (equal amounts per part)
s=np.repeat(np.arange(Ngratings),(Ntrials/Ngratings))
stim=np.random.permutation(s)

print('stim_ok')

# Within-subjects design
TrialList=[]
TrialList.append( {"gratings": stim.astype(int)})
print(TrialList)
trials = data.TrialHandler(trialList = TrialList, nReps=1, method = "sequential")
thisExp.addLoop(trials)

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
    
    trials.addData("Tr", trial)
    
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
goodbye         = visual.TextStim(window,text=( "Dit is het einde van de oefenfase.\n\n"+
                                                "Je hebt in deze fase {} punten verdient.\n\n"+
                                                "Geef een teken aan de afnemer dat je klaar bent").format(str(points)),wrapWidth=50, units="deg",alignHoriz='center', alignVert='bottom')
goodbye.draw()
window.flip()
event.waitKeys(keyList = "space")

thisExp.saveAsWideText(file_name, appendFile=False)
thisExp.abort()
window.close()
core.quit()    