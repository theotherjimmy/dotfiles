{ primary, normal, bright }:
''
{-# LANGUAGE DeriveDataTypeable #-}
import Control.Monad (unless)
import Control.Applicative
import qualified Data.Map.Strict as M
import Data.List (sort,nub,intercalate)
import Data.Monoid ((<>))
import Data.Void
import System.Directory (getHomeDirectory)
import System.FilePath ((</>))
import XMonad
import XMonad.StackSet as W
import XMonad.Actions.Navigation2D
import XMonad.Actions.ShowText
import XMonad.Actions.Submap
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.GridSelect
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops (ewmh, fullscreenEventHook)
import XMonad.Hooks.ManageDocks (docks, avoidStruts)
import XMonad.Layout.ThreeColumns (ThreeCol(ThreeColMid))
import XMonad.Layout.ToggleLayouts
import XMonad.Prompt
import XMonad.Prompt.Directory (directoryPrompt)
import XMonad.Util.Loggers
import XMonad.Util.NamedWindows (getName)
import qualified XMonad.Util.ExtensibleState as XS
import Text.Megaparsec hiding (hidden, Parser, many, some)
import Text.Megaparsec.Char (space, char, numberChar)

data Dec = ParserErrorBundle String Void deriving (Eq, Ord)
type Parser = Parsec Dec String
type ErrBundle = ParseErrorBundle String Dec

data Remote = Remote String (Maybe String) deriving (Read, Show)
data DirSpec = DirSpec [Remote] String deriving (Read, Show)
data Projects = Projects
                { projects :: !(M.Map String DirSpec)
                , previousProject :: !(Maybe WorkspaceId)
                } deriving (Typeable, Read, Show)
instance ExtensionClass Projects where
  initialValue = Projects M.empty Nothing

showPWD :: Maybe DirSpec -> FilePath -> FilePath
showPWD (Nothing) home = home
showPWD (Just (DirSpec [] dir)) home = home </> dir
showPWD (Just (DirSpec (_:_) _)) home = home

currentProject :: X (Maybe DirSpec)
currentProject = gets (W.tag . W.workspace . W.current . windowset)
                >>= lookupProject
  where
    lookupProject :: String -> X (Maybe DirSpec)
    lookupProject name = M.lookup name <$> XS.gets projects

setCurrentProject :: XPConfig -> X ()
setCurrentProject c = do
  name <- gets (W.tag . W.workspace . W.current . windowset)
  directoryPrompt c "Set DirSpec: " $ update name . parseDirSpec
  where
    update :: String -> Either ErrBundle DirSpec -> X ()
    update name (Right ds) = XS.modify $ \s -> s {projects = M.insert name ds $ projects s}
    update name (Left err) = flashText def 4 "Bad dirspec"

parseDirSpec :: String -> Either ErrBundle DirSpec
parseDirSpec input = parse dirSpec "(XMonad input)" input

dirSpec :: Parser DirSpec
dirSpec = space >> DirSpec
          <$> many (try $ remote <* (char ':')) <*> many (noneOf " ")

remote :: Parser Remote
remote =  Remote <$> many (noneOf ":#")
          <*> choice [ char '#' >> Just <$> some numberChar, pure Nothing ]

showSSHremotes :: [Remote] -> String -> String
showSSHremotes [] suffix = suffix
showSSHremotes ((Remote host Nothing):rs) suffix =
  "ssh -A -t " ++ host ++ " " ++ showSSHremotes rs suffix
showSSHremotes ((Remote host (Just port)):rs) suffix=
  "ssh -A -t " ++ host ++ " -p " ++ port ++ " " ++ showSSHremotes rs suffix

showtermSsh :: String -> DirSpec -> String
showtermSsh termCommand (DirSpec [] dir) = "env -C " ++ dir ++ " " ++ termCommand
showtermSsh termCommand (DirSpec remotes "") =
  termCommand ++" -e  bash -c \"" ++ showSSHremotes remotes ""  ++ "\""
showtermSsh termCommand (DirSpec remotes dir) =
  termCommand ++" -e bash -c \""
  ++ showSSHremotes remotes ("\'mkdir -p " ++ dir
                            ++ "; cd " ++ dir
                            ++ "; bash --login\'")
  ++ "\""

showEnvSsh :: String -> DirSpec -> String
showEnvSsh cmd (DirSpec _ "") = cmd
showEnvSsh cmd (DirSpec _ dir) = "env -C " ++ dir ++ " " ++ cmd

remThing ::  (String -> DirSpec -> String) -> String -> X ()
remThing showfn termCommand =
  currentProject >>= term'
  where term' (Just ds) = spawn $ showfn termCommand ds
        term' (Nothing) = spawn termCommand

remTerm :: String -> X ()
remTerm = remThing showtermSsh

remSpawn :: String -> X ()
remSpawn = remThing showEnvSsh

gsConfigWS :: GSConfig WorkspaceId
gsConfigWS = def
gsConfigWin :: GSConfig Window
gsConfigWin = def
gsConfigLay :: GSConfig [Char]
gsConfigLay = def

myGridselectWorkspace :: GSConfig WorkspaceId
                      -> (WorkspaceId -> WindowSet -> WindowSet) -> X ()
myGridselectWorkspace conf viewFn = withWindowSet $ \ws -> do
  let wss = sort $ map W.tag $ W.hidden ws ++ map W.workspace (W.current ws : W.visible ws)
  gridselect conf (zip wss wss) >>= flip whenJust (windows . viewFn)

myGridselectWindows :: GSConfig Window -> X ()
myGridselectWindows config = gets workspaceWindows >>= mapM keyValuePair
                            >>= gridselect config >>= maybe (pure ()) (windows . W.focusWindow)
  where decorateName' w = show <$> getName w
        keyValuePair w = flip (,) w <$> decorateName' w
        workspaceWindows = nub . W.integrate' . W.stack . W.workspace . W.current . windowset

mykeys :: XConfig t -> M.Map (KeyMask, KeySym) (X ())
mykeys (XConfig {XMonad.modMask = modm}) = M.fromList
      -- Window Navigation --
      [ ((modm, xK_l), windowGo R False)
      , ((modm, xK_h), windowGo L False)
      , ((modm, xK_j), windowGo D False)
      , ((modm, xK_k), windowGo U False)
      , ((modm .|. shiftMask, xK_l), windowSwap R False)
      , ((modm .|. shiftMask, xK_h), windowSwap L False)
      , ((modm .|. shiftMask, xK_j), windowSwap D False)
      , ((modm .|. shiftMask, xK_k), windowSwap U False)

      , ((modm, xK_t),submap . M.fromList $
        [ ((0, xK_n), goToSelected gsConfigWin)
        , ((modm, xK_n), myGridselectWindows gsConfigWin)

        -- Window Creation --
        -- # Terminal --
        , ((0, xK_c), spawn "alacritty")
        , ((modm, xK_c), remTerm "alacritty")

        -- # Run CMD --
        , ((0, xK_p), spawn "rofi -show run")
        , ((modm, xK_p), remSpawn "rofi -show run")

          -- Groups --
        , ((modm, xK_g), spawn "rofi-switch-workspaces")
        , ((modm .|. shiftMask, xK_g), myGridselectWorkspace gsConfigWS
                                        (\ws -> W.greedyView ws . W.shift ws))
        , ((0, xK_g), submap . M.fromList $
          [ ((0, xK_d), removeWorkspace)
          , ((0, xK_c), addWorkspacePrompt def)
          , ((0, xK_r), renameWorkspace def)
          , ((0, xK_e), setCurrentProject def)
          , ((0, xK_n), myGridselectWorkspace gsConfigWS W.greedyView)
          , ((shiftMask, xK_n), myGridselectWorkspace gsConfigWS
                                (\ws -> W.greedyView ws . W.shift ws))
          , ((0, xK_s), gridselectWorkspace gsConfigWS W.greedyView)
          ])
          --layout map
        , ((modm, xK_l), sendMessage ToggleLayout)
        , ((0, xK_l), submap . M.fromList $
          [ ((0, xK_n), sendMessage ToggleLayout)
          , ((0, xK_comma), sendMessage (IncMasterN 1))
          , ((0, xK_period), sendMessage (IncMasterN (-1)))
          , ((0, xK_h), sendMessage Expand)
          , ((0, xK_l), sendMessage Shrink)
          ])
        , ((0, xK_k), kill)
        ])
      ]

nav2DConfig :: XConfig xs -> XConfig xs
nav2DConfig = withNavigation2DConfig
  $ def { layoutNavigation = [("Full", centerNavigation)]
        , unmappedWindowRect = [("Full", singleWindowRect)]
        }

xmonadConfig =
  def { keys = mykeys
      , terminal = "alacritty"
      , borderWidth = 2
      , focusFollowsMouse = True
      , layoutHook = avoidStruts $ toggleLayouts Full $ ThreeColMid 1 (1/20) (2/5)
      , XMonad.workspaces = ["Browser", "Other"]
      , handleEventHook = handleEventHook def <+> fullscreenEventHook <+> handleTimerEvent
      , normalBorderColor = "${primary.bg-soft}"
      , focusedBorderColor = "${normal.yellow}"
      }

main :: IO()
main = xmonad $ nav2DConfig $ ewmh $ docks $ xmonadConfig
''
