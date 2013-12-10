# Created by: Spencer McClain, NULLify
# Created for the 2013: A H4CK Odyssey event
# Description: Server Application that generates a random number for each session
# -------------------------------------------------
from twisted.internet import protocol, reactor
from twisted.protocols.basic import LineReceiver
import random
from datetime import datetime

# log file
log = 'pinGuess.log'

# Port Number
PORT = 8888

#class Echo(protocol.Protocol):
class Echo(LineReceiver):
    def __init__(self, data):
        rand = random.randint(0, 9999)
        if len(str(rand)) < 4:
            buff = ''
            for i in range(4 - len(str(rand))):
                buff = buff + '0'
            rand = buff + str(rand)
        self.number = str(rand)
        #print 'The number is ' + self.number # Prints the pin to the server console
        self.name = "GETUSER"

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

    def dataReceived(self, data):
        if self.name == "GETUSER":
            self.name = data.strip()
            self.transport.write('PIN: ')
        else:
            guess = data.strip()
            #print self.name + ' guessed ' + guess
            if self.number in guess:
                f = open(log, 'a')
               # print self.name + ' got it right!'
                self.transport.write('\nYou are CORRECT! Key={KEYKEYKEYKEY}\n')
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
        self.number = ''

    def buildProtocol(self, addr):
        return Echo(self.number)

reactor.listenTCP(PORT, EchoFactory())
reactor.run()
