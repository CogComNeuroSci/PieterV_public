from __future__ import division
from psychopy import visual,data,event,core,gui,parallel
import time
import numpy as np
from numpy import random
import os
import math
import pandas


send_eegtriggers = False
trigger_on_time = .01

if send_eegtriggers:
    # Address for the parallel port in the biosemi setup
    parallel.setPortAddress(0xC020)
    # this sends the trigger, usually initialize it at zero
    # then the trigger, then a wait-function for e.g. 30 ms, and zero again
    parallel.setData(0)
    time.sleep(trigger_on_time)
    
#define amounts of everything
Nstim=2
Nresp=2
Ntrials=50

#Initialize data
response=0

print('initialization_ok')

#make data file
info= {"ppnr": 0}

# Data file
already_exists = True
while already_exists:
    myDlg = gui.DlgFromDict(dictionary = info, title = "test")
    directory_to_write_to = "/Users/Pieter/Desktop" + "/" + str(info["ppnr"])
    if not os.path.isdir(directory_to_write_to):
        os.mkdir(directory_to_write_to)
    file_name = directory_to_write_to + "/test" + str(info["ppnr"]) 
    if not os.path.isfile(file_name+".tsv"):
        already_exists = False
    else:
        myDlg2 = gui.Dlg(title = "Error")
        myDlg2.addText("Try another participant number")
        myDlg2.show()
print("OK, let's get started!")

thisExp = data.ExperimentHandler(dataFileName = file_name, extraInfo = info)

#make window
window=visual.Window(fullscr=False, size=(800,600), monitor='testMonitor', color=[0,0,0],colorSpace='rgb') 

print('window_ok')

#clocks
my_clock= core.Clock()
sleepclock=core.Clock()

#elements of trials
t1 = [0.01]*Ntrials
t2= [0.02]*Ntrials
t3=[0.05]*Ntrials
sleeptime=np.column_stack((t1, t2, t3))
print(sleeptime)

fixation = visual.TextStim(window,text=("+"))

grating=visual.GratingStim(win=window,tex='sin', mask='raisedCos',ori=90, pos=(0,0), size= (7,7), units='deg', interpolate=False)

feedback=visual.TextStim(window,text=("Bravo"))
print('stim_ok')

# Within-subjects design
TrialList=[]
TrialList.append( {"sleeptimes": sleeptime})
print(TrialList)
trials = data.TrialHandler(trialList = TrialList, nReps=1, method = "sequential")
thisExp.addLoop(trials)

# welcome screen
welcome=visual.TextStim(window,text=("Welkom"))
welcome.draw()
window.flip()
event.waitKeys(keyList = "space")


sleepclock.reset()
#trial loop   
for trial in range(Ntrials):
    
    trials.addData("Tr", trial)
    
    fixation.draw()
    window.flip()
    
    t1_on=sleepclock.getTime()
    
    if send_eegtriggers:
        # trigger for fixation
        parallel.setData(int(np.binary_repr(50, 8), 2))
        time.sleep(sleeptime[trial,0])
        parallel.setData(int(np.binary_repr(0, 8), 2))
    else:
        time.sleep(sleeptime[trial,0])
        
    
    t1_off=sleepclock.getTime()
    t1_diff=t1_off-t1_on
    
    time.sleep(0.5)
    
    grating.draw()
    window.flip()
    
    t2_on=sleepclock.getTime()
    if send_eegtriggers:
        # trigger for grating
        parallel.setData(int(np.binary_repr(60, 8), 2))
        time.sleep(sleeptime[trial,1])
        parallel.setData(int(np.binary_repr(0, 8), 2))
    else:
        time.sleep(sleeptime[trial,1])
        
        
    t2_off=sleepclock.getTime()
    t2_diff=t2_off-t2_on
    
    time.sleep(0.5)
    
    feedback.draw()
    window.flip()
    
    t3_on=sleepclock.getTime()
    if send_eegtriggers:
        # trigger for feedback
        parallel.setData(int(np.binary_repr(70, 8), 2))
        time.sleep(sleeptime[trial,2])
        parallel.setData(int(np.binary_repr(0, 8), 2))
    else:
        time.sleep(sleeptime[trial,2])
        
    t3_off=sleepclock.getTime()
    t3_diff=t3_off-t3_on
    
    time.sleep(0.5)
    
    print(trial)
    
    trials.addData("t1_on", t1_on)
    trials.addData("t1_off", t1_off)
    trials.addData("t1_diff", t1_diff)
    
    trials.addData("t2_on", t2_on)
    trials.addData("t2_off", t2_off)
    trials.addData("t2_diff", t2_diff)
    
    trials.addData("t3_on", t3_on)
    trials.addData("t3_off", t3_off)
    trials.addData("t3_diff", t3_diff)
    
    thisExp.nextEntry()

#say goodbye to the participant
goodbye         = visual.TextStim(window,text=( "Dada"),wrapWidth=50, units="deg",alignHoriz='center', alignVert='bottom')
goodbye.draw()
window.flip()
event.waitKeys(keyList = "space")

thisExp.saveAsWideText(file_name, appendFile=False)
thisExp.abort()
window.close()
core.quit()    