# Set Up

  0. Starting with this direction as the root...
  1. Set up python venv

  python -m venv venv

  2. Activate venv

  [windows cmd] venv\Scripts\activate.bat
  [windows ps]  venv\Scripts\Activate.ps1

  [*nix] source venv/bin/activate

  3. Install requirements

  pip install -r requirements.txt

# Steps

  Guess for how to piece this together

  1. Speech to Text
  2. Input Text as Prompt to Chat Bot
  3. Chat Bot generates response
  4. Text to Speech the response

## Speech to Text (STT)

  Should mic listen all the time for a start and end phrase?
  Or should mic listen on a key?
  
  Maybe also have a mute switch that'll disable all listening and responding?

## Input Text

  Take the text from STT step and input it as a prompt into a chat bot
  Maybe add some hardcoded filters for the text generated?

## Chat Bot Response

  Chat bot generates a response
  Maybe add some extra hardcoded filters on response just in case?
  
## Text to Speech (TTS)

  This may be the simplest part if host OS TTS is available and used

### Chatbot

  Currently looking to modify this project, or at least borrow heavily from it:
  https://github.com/oobabooga/text-generation-webui

### STT Models

  Using vosk library, you can find models at:
  https://alphacephei.com/vosk/models

  Place downloaded model in ./models dir (contents have been .gitignored)

### Chatbot Models

  Big library to choose from here:
  https://huggingface.co/models

  A tested working (CPU only) model:
  https://huggingface.co/WizardLMTeam/WizardMath-7B-V1.1
 
# main.py

  Eventual place for all python code. First commit is just boilerplate to test python environment

  Hit q or esc to quit
