# Created by: Michael George, NULLify 
# Created for 2013: A H4CK Odyssey event
# Description: Server application that generates a random list for each sorting session
# -------------------------------------------------
from twisted.internet import protocol, reactor, task
from twisted.protocols.basic import LineReceiver
import random
from datetime import datetime

# log file
log = "sort.log"
count = 0
_timeout = 5
# Port Number
PORT = 3113
class Echo(LineReceiver):
    def qsortr(list):
        return [] if list==[]  else qsortr([x for x in list[1:] if x < list[0]]) + [list[0]] + qsortr([x for x in list[1:] if x >= list[0]])
    def __init__(self, data):
	self.numbers = []
        self.name = "GETUSER"
        x = 0
        for x in range (0 , 8):
            newnum = random.randint(0,100)
            self.numbers.append(newnum)    
    def connectionMade(self):
        f = open(log, 'a')
        client = self.transport.getPeer()
        print 'Client connect ',
        f.write('Client connect ')
        print client,
        f.write(str(client))
        print 'at ' + str(datetime.now())
        f.write('at ' + str(datetime.now()) + '\n')
        self.transport.write('Team name: ')
        f.close()
        self.timeout = reactor.callLater(_timeout,self.timeOut)
    def timeOut(self):
        self.transport.loseConnection()
    def dataReceived(self, data):
        if self.name == "GETUSER":
            self.name = data.strip()
            #lists = "".join(self.numbers)
            for f in self.numbers:
                self.transport.write(str(f)+" ")
                #print lists
            self.transport.write("\n")
            self.transport.write('Sorted numbers: ')
        else:
            guess = data.strip()
            guess = guess.split()
            guess = [int(x) for x in guess]
#            print qsortr(self.numbers)
#            print self.numbers
            self.numbers.sort()
#            print self.numbers
#            print "-----testing--------"
#            print "guess:"+str(guess)
#            print "numbers:"+str(self.numbers)
            #print self.name + ' guessed ' + guess
#            correctness = cmp(self.numbers,guess) 
#            print correctness
            if str(guess) == str(self.numbers):
                f = open(log, 'a')
               # print self.name + ' got it right!'
                self.transport.write('\nYou get a key! Key={sample_key}\n')
                client = self.transport.getPeer()
                print '\n' + self.name + ' found key'
                f.write("<KEY FOUND>"  + self.name + "\n")
                print client,
                f.write(str(client))
                print 'at ' + str(datetime.now())
                f.write('at ' + str(datetime.now()) + '\n')
                self.transport.loseConnection()
                f.close()
            else:
                self.transport.write('Invalid, try again!\n')



class EchoFactory(protocol.Factory):
    def __init__(self):
        self.numbers = {}

    def buildProtocol(self, addr):
        return Echo(self.numbers)

reactor.listenTCP(PORT, EchoFactory(),interface='0.0.0.0')
reactor.run()
