from mimetypes import init
from os import stat
import sys
import numpy as np
import random
from math import exp
import gym
from collections import deque

from numpy.lib.function_base import gradient


alpha = 0.1
#----------khởi tạo mạng-----------
def initial(neuron_struct, command):
    network = []
    previous = neuron_struct[1]
    for i in range (neuron_struct[0]-1):
        current = neuron_struct[i+2]
        if (command=="random"):
            layer = [[random.uniform(-1,1) for i in range(previous+1)] for i in range(current)]
        elif (command=="one"):
            layer = [[1 for i in range(previous+1)] for i in range(current)]
        else: # Create array zeros
            layer = [[0 for i in range(previous+1)] for i in range(current)]
        previous = current
        network.append(layer)

    return network


##-----------PHẦN TÍNH FORWARD-------



def sigmoid(activation):
    return 1.0 / (1.0 + exp(-activation))


def relu (value_node):
    return max(0, value_node)


def leakyRelu (value_node):

    if(value_node < 0):
      return value_node*0.25
    else:
      return value_node*0.5
    

# def leakyRelu (value_node):

#     if(value_node < 0):
#       return value_node*0.1
#     else:
#       return value_node*0.2

def leakyRelu1(value_node):
    if(value_node <0 ):
        return value_node*0.1
    else: 
        return value_node

def forward_calculation_node (weights, inputs, select_activate):
    # print("weight", weights)
    # print("input", inputs)
    value_node = weights[-1]
    for i in range(len(inputs)):
        value_node += weights[i]*inputs[i]

        # print(weights[i], inputs[i])

        #CHECK OVER FLOW NaN
        if not  (value_node< np.finfo(np.double).max):
            print("OUT_VALUE")
            print(weights[i], inputs[i])
            # print(weights)
            # save_net(weights, "ERROR_NET")
            sys.exit()
        ## END CHECK
    #TINH OUTPUT QUA ACTIVE

    if (select_activate=="sigmoid"):
        return sigmoid(value_node)
    elif(select_activate=="relu"):
        return relu(value_node)
    elif(select_activate =="leakyRelu"):
        return leakyRelu(value_node)
    elif("linear"):
        return value_node

################## TÍNH FORWARD
def forward (network, inputs):
    outputs = [inputs]
    out_layer = inputs
    
    for layer in network[:-1]: ## TRỪ RA LAST LAYER
        next_layer = []
        
        for node in layer:
            value_node = forward_calculation_node (node, out_layer, "leakyRelu")
            next_layer.append(value_node)
        
        outputs.append(next_layer)
        out_layer = next_layer
    
    next_layer = []
    for node in network[-1]: ## LAST LAYER, dùng LINEAR -> ko xài activate
        value_node = forward_calculation_node (node, out_layer, "linear")
        next_layer.append(value_node)
        
    outputs.append(next_layer)
    out_layer = next_layer
    return outputs


#-----------PHẦN TÍNH BACKWARD-----------



def back_sigmoid(value_node):
    return value_node * (1.0 - value_node)


def back_relu (value_node):
    back_value = 0
    if (value_node>0):
        back_value = 1
    return back_value

def back_leakyRelu(value_node):
  back_value = 0.1
  if (value_node > 0):
    back_value = 0.2
  return back_value

# def back_leakyRelu(value_node):
#   back_value = 0.25
#   if (value_node > 0):
#     back_value = 0.5
#   return back_value

def back_leakyRelu1(value_node):
    back_value = 0.1
    if(value_node > 0 ):
        back_value = 1
    return back_value


def deactivate (value_node, select_back_active):
    if (select_back_active=="sigmoid"):
        return back_sigmoid(value_node)
    elif(select_back_active=="relu"):
        return back_relu(value_node)
    elif(select_back_active=="leakyRelu"):
        return back_leakyRelu(value_node)
    elif(select_back_active=="linear"):
        return 1

#---------------- TÍNH ERROR - BACKWARD
def backward (network, outputs, expected):

    Err = [[0 for y in range(len(outputs[x]))] for x in range(len(outputs))] ## LẤY SIZE CỦA NEURON
    E   = [[0 for y in range(len(outputs[x]))] for x in range(len(outputs))]
  

    for i in reversed(range(len(outputs))):
        layer = outputs[i]
        errors = list()
        # print("layer",layer)
        if i == len(outputs)-1: 
            for j in range(len(layer)):
                # print("layer[j]",layer[j])
                errors.append((expected[j]-layer[j]))
        ## NOT LAST LAYER
        else: 
            for j in range(len(layer)):
                error = 0.0
                for pos_weight in range(len(network[i+1])):
                    # print("pos_weight", Err[i+1][pos_weight])
                    error += network[i+1][pos_weight][j] * Err[i+1][pos_weight]
                    ## TÍNH TỔNG TRÊN TẤT CẢ CÁC WEIGHT TRỞ NGƯỢC
                errors.append(error)
        # print("ERROR", errors)
        # CALCULATION Err
        for j in range(len(layer)):
            ## LINEAR CHO LAST LAYER
            if i != len(outputs)-1: 
                # print("NONE", deactivate(layer[j], "relu"))
                Err[i][j] = errors[j]*deactivate(layer[j], "leakyRelu")
                E[i][j] = errors[j]
            else:
            ## RELU CHO CÁC LAYER CÒN LẠI
                # print("LAST", layer[j], deactivate(layer[j], "linear"))
                Err[i][j] = errors[j]*deactivate(layer[j], "linear")
                E[i][j]   = errors[j]
        # print("ERROR-R", Err)
    return Err

################## TÍNH DELTA - BACKWARD
### DÙNG CLIP ĐỂ NORMALIZE CHO GRADIENT TRÁNH BỊ EXPLODING GRADIENT (overflow-underflow: giá trị weight đạt inf hoặc ~0)
def clip_gradient(gradient_delta, min_g, max_g):
    # print("------------------------GD",gradient_delta)
    for i in range(len(gradient_delta)):
        if (gradient_delta[i]>max_g):
            gradient_delta[i] = max_g
        if (gradient_delta[i]<min_g):
            gradient_delta[i] = min_g
    return 

def cal_delta(network, outputs, error):#, min_g, max_g):
    delta = [[[0 for z in range(len(network[x][y]))] for y in range(len(network[x]))] for x in range(len(network))]

    for _ in range(len(network)):        
        for j in range(len(error[_])):            
            for i in range(len(outputs[_])):                         
                delta[_][j][i] = outputs[_][i]*error[_][j]
            delta[_][j][-1] = error[_][j]
            ## CLIPPING
            # clip_gradient(delta[_][j], min_g, max_g)

    return delta


#------------UPDATE NETWORK------------------------------------


# CỘNG MẠNG DELTA
def add(delta_base, delta_add, command):
    if (command=="None"):
        return delta_base
    else:
        for i in range(len(delta_base)):
            for j in range(len(delta_base[i])):
                for k in range(len(delta_base[i][j])):
                    delta_base[i][j][k] += delta_add[i][j][k]
    return delta_base

# CHIA MẠNG DELTA
def div(delta, batch_size):
    for i in range(len(delta)):
        for j in range(len(delta[i])): 
            for k in range(len(delta[i][j])):
                delta[i][j][k] = delta[i][j][k]/batch_size
    return delta

# HÀM CẬP NHẬT MẠNG
def update_weights(network, delta, learning_rate):
    for i in range(len(network)):
        for j in range(len(network[i])):
            for k in range(len(network[i][j])):
                network[i][j][k] = network[i][j][k] +learning_rate*delta[i][j][k]
    return network

# TÍNH THEO MINI-BATCH

def fit_minibatch(network, X_train, Y_train, batch_size, learning_rate, clipping):
    
    
    command = "None"
    for count in range(batch_size):
        ## CLIPPING
        min_g = clipping[count][0]
        max_g = clipping[count][1]

        outputs = forward(network, X_train[count])

        errors = backward(network, outputs[1:], Y_train[count])

        delta = cal_delta(network, outputs, errors, min_g, max_g)

        if (command=="None"):
            sum_delta = delta
            command = "Continue"
        else:
            sum_delta = add(sum_delta, delta, command)


    sum_delta = div(sum_delta, batch_size)

    network = update_weights(network, sum_delta, learning_rate)

def fit(network, X_sample, Y_sample, learning_rate):#, clipping):
    outputs = forward(network, X_sample)

    errors = backward(network, outputs[1:], Y_sample)

    delta = cal_delta(network, outputs, errors)

    network = update_weights(network, delta, learning_rate)


#---------THEO DÕI MẠNG--------------


# XEM TRỌNG SỐ TRONG MẠNG
def display_weights(network, name):
    for i in range(len(network)):
        print("-",name,"- Layer", i+1, ":", "size(", len(network[i][0])-1,",", len(network[i]),")")
        for neuron in network[i]:
            print(np.array(neuron))

def predict(network, inputs):
    # print("predic",forward(network, inputs)[-1])
    return forward(network, inputs)[-1]

def save_net(network, file_name):
    text_file = open(file_name+".txt", "w+")

    number_layer_weights_network = str(len(network))
    text_file.write(number_layer_weights_network + "\n")

    for i in range(len(network)):
        text_layer = open(file_name + "_layer_" + str(i+1) +".txt", "w+")

        number_next_layer_nodes = str(len(network[i]))
        number_this_layer_nodes = str(len(network[i][0]))
        text_file.write((number_next_layer_nodes) + " " + (number_this_layer_nodes) + "\n")

        for j in range(len(network[i])):
            for weights in network[i][j]:
                text_layer.write(str(weights)+"\n")
        
        text_layer.close()

    text_file.close()

def load_net(file_name):
    network = []

    text_file = open(file_name +".txt", "r")

    number_layer_weights_network = int(text_file.readline())

    for i in range(number_layer_weights_network):
        info = text_file.readline().split()
        number_next_layer_nodes = int(info[0])
        number_this_layer_nodes = int(info[1])
        # print(number_next_layer_nodes)
        # print(number_this_layer_nodes)

        layer = []

        text_layer = open(file_name + "_layer_" + str(i+1) + ".txt", "r")

        for a in range(number_next_layer_nodes):
            node = []
            for b in range(number_this_layer_nodes):
                node += [float(text_layer.readline())]
            layer += [node]
        # print("layer", layer)
        network += [layer]
        text_layer.close()
    # print("point check")
    text_file.close()
    # print("load_net",network)
    return network

def copy_net(base_net, cop_net):
    for i in range(len(base_net)):
        for j in range(len(base_net[i])):
            for k in range(len(base_net[i][j])):
                cop_net[i][j][k] = base_net[i][j][k]

def clean_net(net):
    for i in range(len(net)):
        for j in range(len(net[i])):
            for k in range(len(net[i][j])):
                net[i][j][k] = 0

def compare_net(net_one, net_two):
    # print(net_one)
    return net_one == net_two


################## OPTIMIZE NETWORK#####################################

def soft_update(base_net, cop_net):
    for i in range(len(base_net)):
        for j in range(len(base_net[i])):
            for k in range(len(base_net[i][j])):
                cop_net[i][j][k] = cop_net[i][j][k]*0.5 + base_net[i][j][k]*0.5


###########################################################################
import matplotlib.pyplot as plt
x = []
y = []
# z = []
# avg_y = []



class DQNAgent:
    def __init__(self,state_size, action_size):
        self.state_size = state_size
        self.action_size = action_size
        self.memory = deque(maxlen=10000)
        self.gamma = 0.8    # discount rate
        self.epsilon = 1.0  # exploration rate
        self.epsilon_min = 0.01
        self.epsilon_decay = 0.997
        self.learning_rate = 0.001
        self.batch_size = 128
        self.train_start = 1000
        self.model = initial([4,self.state_size,32,32,self.action_size],"random")
        self.target_model = initial([4,self.state_size,32,32,self.action_size],"random")


    def update_target_model(self):
        copy_net(self.model, self.target_model)
        # print("update net")clear
        return self.target_model


    def soft_update_target_model(self):
        soft_update(self.model, self.target_model)
        # print("soft update net")
        return self.target_model



    def remember(self, state,action, reward, next_state, done):
        self.memory.append(( state,action, reward, next_state, done))
        if self.epsilon > self.epsilon_min:
            self.epsilon *= self.epsilon_decay

    def act (self, state):
        if np.random.random() <= self.epsilon:
            return random.randrange(self.action_size)
        else:
            act_values = predict(self.model, state[0])
            return np.argmax(act_values)     #returns action

     
    def replay(self):
        if len(self.memory) < self.train_start:
            return
        
        # minibatch = random.sample(self.memory, min(len(self.memory), self.batch_size))
        mini_batch = random.sample(self.memory, self.batch_size)
        state = np.zeros(([self.batch_size, self.state_size]))
        next_state = np.zeros(([self.batch_size, self.state_size]))
        action, reward, done = [], [], []

        for i in range(self.batch_size):
            state[i] = mini_batch[i][0]
            action.append(mini_batch[i][1])
            reward.append(mini_batch[i][2])
            next_state[i] = mini_batch[i][3]
            done.append(mini_batch[i][4])
        # print(len(done))
        # print("state", state)
        target, target_next = [],[]
        for i in range (self.batch_size):
            target.append(predict(self.model,state[i]))
            target_next.append(predict(self.target_model,next_state[i]))

            if done[i]:
                target[i][action[i]] = reward[i]
            else:
                target[i][action[i]] = reward[i] + self.gamma*(max(target_next[i]))

            fit(self.model, state[i], target[i], self.learning_rate)
        
        self.soft_update_target_model()
        

   


    def save(self, name):
        save_net(self.model,name)

    def load(self, name):
        copy_net(load_net(name),self.model)
        print("load net succefful")
        return self.model


EPISODES = 1000

if __name__  == "__main__":
    env = gym.make('MountainCar-v0')
    state_size = env.observation_space.shape[0]
    action_size = env.action_space.n
    agent = DQNAgent(state_size, action_size)
    
    # print("state size:", state_size)9
    # print("action size:", action_size)

    # print("initial net",agent.model)
    agent.load('/home/luan/Desktop/PY/DQN_PY/weight_tran/Net32')
    # print(agent.update_target_model())
    agent.target_model = agent.update_target_model()

    # print("-------------------------")
    # print("after net ", agent.model)



    t = 0
    for e in range(EPISODES):
        state = env.reset()
        state = np.reshape(state, [1, state_size])
        # print(state)
        flag = 0
        done = False
        scores = 0
        max_pos = -1.2
        time = 0
        while not done:
    
            # env.render()
            action = agent.act(state)
            next_state, reward, done, info = env.step(action)

            if state[0][0]> max_pos:
                max_pos = state[0][0]

            if next_state[1] > state[0][1] and next_state[1]>0 and state[0][1]>0:
                reward += 15
            elif next_state[1] < state[0][1] and next_state[1]<=0 and state[0][1]<=0:
                reward +=15

            if done:
                reward = reward + 100
            else:
                # put a penalty if the no of time steps is more
                reward = reward -  10
                
            next_state = np.reshape(next_state, [1, state_size])
            agent.remember(state, action, reward, next_state, done)
            state = next_state
            scores += reward
            time += 1
 
            if done:
                t  += 1
                x.append(t)
                y.append(scores)
                flag = 1
                if len(agent.memory) > agent.batch_size :
                    agent.replay()

                # agent.soft_update_target_model()
    
                print("episode: {}/{}, score: {}, e: {:.2},max_pos: {}, time: {}"
                      .format(e, EPISODES, scores, agent.epsilon,max_pos, time))
                break

        if flag == 0:
            print("episode: {}/{}, score: {}, e: {:.2}".format(e, EPISODES, time, agent.epsilon))      
        # if e % 200 == 0:
        #     print('saving the model')
        #     agent.save("/home/luan/Desktop/PY/DQN_PY/weight_tran/Weight_SGD_v4")
  



    plt.plot(x, y, label = 'DQN')
    plt.xlabel('Epoch Number')
    plt.ylabel('Epoch step')

    plt.legend()
    plt.show()
