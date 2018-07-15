{-# OPTIONS_GHC -fno-warn-partial-type-signatures #-}

module Flight.LatLng
    ( QLat
    , Lat(..)
    , QLng
    , Lng(..)
    , LatLng(..)
    , DegToRad
    , RadToDeg
    , AzimuthFwd
    , AzimuthRev
    , degToRadLL
    , radToDegLL
    , fromDMS
    ) where

import GHC.Generics (Generic)
import Data.Aeson (FromJSON(..), ToJSON(..))
import Data.UnitsOfMeasure (KnownUnit, Unpack, u, convert)
import Data.UnitsOfMeasure.Internal (Quantity(..))
import Data.UnitsOfMeasure.Convert (Convertible)
import Test.SmallCheck.Series as SC (Serial(..), cons2, decDepth)
import Test.Tasty.QuickCheck as QC (Arbitrary(..), arbitraryBoundedRandom)

import Flight.Units ()
import Flight.Units.DegMinSec (DMS(..), toDeg)
import Flight.LatLng.Lat (QLat, Lat(..))
import Flight.LatLng.Lng (QLng, Lng(..))
import Flight.LatLng.Family

-- | A function calculating the forward azimuth between two points given as
-- latitude longitude pairs in radians.
type AzimuthFwd a
    = LatLng a [u| rad |]
    -> LatLng a [u| rad |]
    -> Maybe (Quantity a [u| rad |])

-- | A function calculating the reverse azimuth between two points given as
-- latitude longitude pairs in radians.
type AzimuthRev a
    = LatLng a [u| rad |]
    -> LatLng a [u| rad |]
    -> Maybe (Quantity a [u| rad |])

newtype LatLng a u = LatLng (QLat a u, QLng a u) deriving (Eq, Ord, Generic)
deriving anyclass instance (ToJSON (QLat a u), ToJSON (QLng a u)) => ToJSON (LatLng a u)
deriving anyclass instance (FromJSON (QLat a u), FromJSON (QLng a u)) => FromJSON (LatLng a u)

fromDMS :: (DMS, DMS) -> LatLng Double [u| rad |]
fromDMS (lat, lng) =
    LatLng (Lat lat'', Lng lng'')
        where
            lat' :: Quantity Double [u| deg |]
            lat' = MkQuantity . toDeg $ lat

            lng' :: Quantity Double [u| deg |]
            lng' = MkQuantity . toDeg $ lng

            lat'' = convert lat' :: Quantity _ [u| rad |]
            lng'' = convert lng' :: Quantity _ [u| rad |]

instance
    (KnownUnit (Unpack u), Show (QLat a u), Show (QLng a u))
    => Show (LatLng a u) where
    show (LatLng (lat, lng)) = "(" ++ show lat ++ ", " ++ show lng ++ ")"

-- | Conversion of a lat/lng pair from degrees to radians.
degToRadLL :: DegToRad a -> LatLng a [u| deg |] -> LatLng a [u| rad |]
degToRadLL degToRad (LatLng (Lat lat, Lng lng)) =
    LatLng (Lat lat', Lng lng')
    where
        lat' = degToRad lat
        lng' = degToRad lng

-- | Conversion of a lat/lng pair from radians to degrees.
radToDegLL :: RadToDeg a -> LatLng a [u| rad |] -> LatLng a [u| deg |]
radToDegLL radToDeg (LatLng (Lat lat, Lng lng)) =
    LatLng (Lat lat', Lng lng')
    where
        lat' = radToDeg lat
        lng' = radToDeg lng

instance
    ( Monad m
    , SC.Serial m a
    , Real a
    , Fractional a
    , Convertible u [u| deg |]
    , u ~ [u| rad |]
    )
    => SC.Serial m (LatLng a u) where
    series = decDepth $ LatLng <$> cons2 (\lat lng -> (lat, lng))

instance
    ( Real a
    , Fractional a
    , Arbitrary a
    , Convertible u [u| deg |]
    , u ~ [u| rad |]
    )
    => QC.Arbitrary (LatLng a u) where
    arbitrary = LatLng <$> do
        lat <- arbitraryBoundedRandom
        lng <- arbitraryBoundedRandom
        return (lat, lng)
