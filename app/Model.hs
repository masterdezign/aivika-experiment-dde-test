
{-# LANGUAGE RecursiveDo #-}
module Model where

import Data.Array

import Simulation.Aivika
import Simulation.Aivika.SystemDynamics
import Simulation.Aivika.Experiment

import Simulation.Aivika.Internal.Specs
import Simulation.Aivika.Internal.Parameter
import Simulation.Aivika.Internal.Dynamics

-- Mackey-Glass delay equation
model :: Simulation Results
model =
  mdo -- xTau <- delayI x tauD 0.2
      x <- integ (beta * xTauPrecise / (1 + xTauPrecise^10) - gamma * x) 0.2
      let gamma = 0.1
          beta = 0.2
          -- tauD = 17  -- Delay time
          k = 170  -- Samples per delay

      let xTauPrecise =
            Dynamics $ \p ->
            if pointIteration p > k
            then let n = pointIteration p
                 in invokeDynamics (points ! (n - k)) x
            else return 0.2

      points <- liftParameter $
        Parameter $ \r ->
        do let xs = integPoints r
               bnds = integIterationBnds (runSpecs r)
           return $
             listArray bnds xs

      return $ results
        [resultSource "t" "time" time,
         resultSource "x" "variable x" x]

modelIkeda :: Simulation Results
modelIkeda =
  mdo -- xTau <- delayI x tauD 0.2
      x <- integ ((-x + beta * 0.5 * (1 - (cos $ 2 * (xTauPrecise + phi0))))/epsilon) 0.2
      let phi0 = 0.2
          beta = 3
          epsilon = 0.005
          -- tauD = 1  -- Delay time
          k = 2000

      points <- liftParameter $
        Parameter $ \r ->
        do let xs = integPoints r
               bnds = integIterationBnds (runSpecs r)
           return $
             listArray bnds xs

      let xTauPrecise =
            Dynamics $ \p ->
            if pointIteration p > k
            then let n = pointIteration p
                 in invokeDynamics (points ! (n - k)) x
            else return 0.2

      return $ results
        [resultSource "t" "time" time,
         resultSource "x" "variable x" x]
