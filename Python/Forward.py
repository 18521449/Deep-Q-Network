# from ctypes.wintypes import PINT
from mimetypes import init
import sys
import numpy as np
import random
from math import exp
import gym
from collections import deque

from numpy.lib.function_base import gradient

alpha = 0.1 
##-----------PHẦN TÍNH FORWARD-------

def sigmoid(activation):
    return 1.0 / (1.0 + exp(-activation))


def relu (value_node):
    return max(0, value_node)

def leakyRelu (value_node):

    if(value_node < 0):
      return value_node*alpha 
    else:
      return value_node
    
def forward_calculation_node (weights, inputs, select_activate):
  
    value_node = weights[-1]
    for i in range(len(inputs)):
        value_node += weights[i]*inputs[i]
        if not (value_node< np.finfo(np.double).max):
            # print("OUT_VALUE")
            # print(weights[i], inputs[i])
            # print(weights)

            #save_net(weights, "ERROR_NET")
            sys.exit()
    
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
##########################################
#-----------PHẦN TÍNH BACKWARD-----------#
##########################################


def back_sigmoid(value_node):
    return value_node * (1.0 - value_node)


def back_relu (value_node):
    back_value = 0
    if (value_node>0):
        back_value = 1
    return back_value

def back_leakyRelu(value_node):
  back_value = 1
  if (value_node < 0):
    back_value = alpha
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
    # print("error",Err)

    for i in reversed(range(len(outputs))):
        layer = outputs[i]
        errors = list()
        # print("layer",layer)
        if i == len(outputs)-1: 
            for j in range(len(layer)):
                # print("layer[j]",layer[j])
                errors.append((layer[j]-expected[j]))
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
            else:
            ## RELU CHO CÁC LAYER CÒN LẠI
                # print("LAST", layer[j], deactivate(layer[j], "linear"))
                Err[i][j] = errors[j]*deactivate(layer[j], "linear")
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

def cal_delta(network, outputs, error, min_g, max_g):
    delta = [[[0 for z in range(len(network[x][y]))] for y in range(len(network[x]))] for x in range(len(network))]

    for _ in range(len(network)):        
        for j in range(len(error[_])):            
            for i in range(len(outputs[_])):                         
                delta[_][j][i] = outputs[_][i]*error[_][j]
            delta[_][j][-1] = error[_][j]
            ## CLIPPING
            clip_gradient(delta[_][j], min_g, max_g)

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


# HÀM CẬP NHẬT MẠNG
def update_weights(network, delta, learning_rate):
    for i in range(len(network)):
        for j in range(len(network[i])):
            for k in range(len(network[i][j])):
                network[i][j][k] -= learning_rate*delta[i][j][k]
    return network

# TÍNH THEO SGD


def fit(network, X_sample, Y_sample, learning_rate):#, clipping):

    outputs = forward(network, X_sample)

    errors = backward(network, outputs[1:], Y_sample)

    delta = cal_delta(network, outputs, errors)

    network = update_weights(network, delta, learning_rate)

