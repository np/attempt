{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE Rank2Types #-}
---------------------------------------------------------
--
-- Module        : Control.Monad.Attempt.Class
-- Copyright     : Michael Snoyman
-- License       : BSD3
--
-- Maintainer    : Michael Snoyman <michael@snoyman.com>
-- Stability     : Unstable
-- Portability   : portable
--
---------------------------------------------------------

-- | Defines a type class for any monads which may report failure using
-- extensible exceptions.
module Control.Monad.Attempt.Class
    ( MonadAttempt (..)
    , StringException (..)
    ) where

import Control.Exception
import Data.Generics

-- | Any 'Monad' which may report failure using extensible exceptions. This
-- most obviously applies to the Attempt data type, but you should just as well
-- use this for arbitrary 'Monad's.
--
-- Usage should be straight forward: 'return' successes and 'failure' errors.
-- If you simply want to send a string error message, use 'failureString'.
-- Although tempting to do so, 'fail' is *not* used as a synonym for
-- 'failureString'; 'fail' should not be used at all.
--
-- Minimal complete definition: 'failure' and 'wrapFailure'.
class (Functor m, Monad m) => MonadAttempt m where
    failure :: Exception e => e -> m v

    -- | Call 'failure' by wrapping the argument in a 'StringException'.
    failureString :: String -> m v
    failureString = failure . StringException

    -- | Wrap the failure value, if any, with the given function. This is
    -- useful in particular when you want all the exceptions returned from a
    -- certain library to be of a certain type, even if they were generated by
    -- a different library.
    wrapFailure :: Exception eOut
                => (forall eIn. Exception eIn => eIn -> eOut)
                -> m v
                -> m v

-- | A simple exception which simply contains a string. Note that the 'Show'
-- instance simply returns the contained string.
newtype StringException = StringException String
    deriving Typeable
instance Show StringException where
    show (StringException s) = s
instance Exception StringException
