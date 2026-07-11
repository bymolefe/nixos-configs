#!/usr/bin/env python3
"""
AI Study Helper - Explain highlighted text using Google Gemini
Provides context-aware explanations for studying
"""

import sys
import os
import json
import subprocess
import hashlib
import requests
from pathlib import Path
from datetime import datetime, timedelta
from typing import Optional, Dict, Tuple


PROMPT_TEMPLATES = {
    "explain": {
        "name": "Explain",
        "icon": "󰋖",
        "token_multiplier": 1.0,
        "prompt": """Please explain what the following means:

"{query}"

{context_line}
Provide a clear, concise explanation suitable for studying. If it's a technical term, include examples where helpful."""
    },
    "eli5": {
        "name": "ELI5 (Simple)",
        "icon": "󰒃",
        "token_multiplier": 0.75,
        "prompt": """Explain the following in very simple terms, as if explaining to a beginner with no background knowledge:

"{query}"

{context_line}
Use analogies and everyday examples. Avoid jargon."""
    },
    "examples": {
        "name": "With Examples",
        "icon": "󰉹",
        "token_multiplier": 1.5,
        "prompt": """Explain the following with multiple practical examples:

"{query}"

{context_line}
Focus on concrete examples that demonstrate the concept in action. Include code examples if relevant."""
    },
    "deep": {
        "name": "Deep Dive",
        "icon": "󰊕",
        "token_multiplier": 2.0,
        "prompt": """Provide an in-depth, comprehensive explanation of:

"{query}"

{context_line}
Cover the underlying principles, edge cases, common pitfalls, and advanced considerations. Be thorough."""
    },
    "compare": {
        "name": "Compare/Contrast",
        "icon": "󰆏",
        "token_multiplier": 1.5,
        "prompt": """Explain the following and compare it with similar or related concepts:

"{query}"

{context_line}
Highlight key differences, similarities, and when to use each. Use a structured comparison."""
    },
    "summarize": {
        "name": "Summarize",
        "icon": "󰦨",
        "token_multiplier": 0.5,
        "prompt": """Provide a brief, focused summary of:

"{query}"

{context_line}
Keep it concise - bullet points are fine. Focus on the key takeaways."""
    },
    "code": {
        "name": "Code Explain",
        "icon": "",
        "token_multiplier": 1.5,
        "prompt": """Explain this code or programming concept:

"{query}"

{context_line}
Break down what each part does, explain the logic, and mention any important patterns or best practices."""
    }
}


class ConfigManager:
    """Manages configuration and API key loading"""

    def __init__(self):
        self.config_dir = Path.home() / ".config" / "ai-study-helper"
        self.config_file = self.config_dir / "config.json"
        self.env_file = self.config_dir / ".env"
        self.history_dir = self.config_dir / "history"

        # Ensure directories exist
        self.config_dir.mkdir(parents=True, exist_ok=True)
        self.history_dir.mkdir(parents=True, exist_ok=True)

        # Load or create config
        self.config = self._load_config()

    def _load_config(self) -> dict:
        """Load configuration from JSON file or create default"""
        if self.config_file.exists():
            with open(self.config_file) as f:
                return json.load(f)
        else:
            # Create default config
            default_config = {
                "model": "gemini-2.5-flash",
                "max_tokens": 2048,
                "cache_duration_hours": 24,
                "api_timeout": 30,
                "default_template": "explain"
            }
            with open(self.config_file, 'w') as f:
                json.dump(default_config, f, indent=2)
            return default_config

    def get_api_key(self) -> Optional[str]:
        """Get API key from .env file or environment variable"""
        # Priority 1: .env file
        if self.env_file.exists():
            with open(self.env_file) as f:
                for line in f:
                    line = line.strip()
                    if line.startswith('GEMINI_API_KEY='):
                        return line.split('=', 1)[1].strip()

        # Priority 2: Environment variable
        return os.getenv('GEMINI_API_KEY')

    def setup_api_key(self) -> bool:
        """Prompt user for API key via rofi"""
        try:
            result = subprocess.run(
                ['rofi', '-dmenu', '-password', '-p', 'Enter Google Gemini API Key',
                 '-config', str(Path.home() / '.config/rofi/simple.rasi')],
                capture_output=True,
                text=True
            )

            if result.returncode != 0:
                return False

            api_key = result.stdout.strip()
            if not api_key:
                return False

            # Save to .env file
            with open(self.env_file, 'w') as f:
                f.write(f"GEMINI_API_KEY={api_key}\n")

            # Secure the file
            os.chmod(self.env_file, 0o600)

            # Notify success
            subprocess.run([
                'notify-send', '-u', 'low', '-h', 'int:transient:1',
                'AI Study Helper', 'API key saved securely'
            ])

            return True

        except Exception as e:
            print(f"Error setting up API key: {e}", file=sys.stderr)
            return False


class RofiInterface:
    """Handles all rofi interactions"""

    def __init__(self, config_dir: Path):
        self.config_dir = config_dir
        self.theme = Path.home() / '.config/rofi/ai-study-helper.rasi'
        self.simple_theme = Path.home() / '.config/rofi/simple.rasi'

    def show_template_selector(self, query: str) -> Optional[str]:
        """
        Show rofi menu to select prompt template
        Returns template key or None if cancelled
        """
        try:
            # Build menu items with icons
            menu_items = []
            template_keys = []
            for key, template in PROMPT_TEMPLATES.items():
                menu_items.append(f"{template['icon']}  {template['name']}")
                template_keys.append(key)

            menu_input = "\n".join(menu_items)

            query_preview = query[:50] + "..." if len(query) > 50 else query
            mesg = f"Query: \"{query_preview}\"\n\nSelect explanation style:"

            result = subprocess.run(
                ['rofi', '-dmenu', '-p', 'Style',
                 '-mesg', mesg,
                 '-config', str(self.simple_theme),
                 '-theme-str', 'window { width: 40%; }',
                 '-theme-str', 'listview { lines: 7; }',
                 '-no-custom'],
                input=menu_input,
                capture_output=True,
                text=True
            )

            if result.returncode != 0:
                return None

            # Find which template was selected
            selected = result.stdout.strip()
            for i, item in enumerate(menu_items):
                if item == selected:
                    return template_keys[i]

            return "explain"  # Default fallback

        except Exception as e:
            print(f"Error in template selector: {e}", file=sys.stderr)
            return None

    def show_context_editor(self, text: str) -> Optional[str]:
        """
        Show rofi window for user to review/edit context before sending
        Returns edited context or None if cancelled
        """
        try:
            # Show instructions in the message
            text_preview = text[:80] + "..." if len(text) > 80 else text
            mesg = f"Selected: \"{text_preview}\"\n\nTip: Add surrounding context for better explanations (e.g. paste the paragraph)"

            result = subprocess.run(
                ['rofi', '-dmenu', '-p', 'Context',
                 '-mesg', mesg,
                 '-config', str(self.simple_theme),
                 '-theme-str', 'window { width: 60%; }',
                 '-theme-str', 'entry { placeholder: "Type/paste context, or Enter to use selection only..."; }'],
                input=text,
                capture_output=True,
                text=True
            )

            if result.returncode != 0:
                # User cancelled
                return None

            # Return the edited context (or original if unchanged)
            edited = result.stdout.strip()
            return edited if edited else text

        except Exception as e:
            print(f"Error in context editor: {e}", file=sys.stderr)
            return None

    def show_context_confirmation(self, query: str, context: str) -> Optional[str]:
        """
        Show confirmation dialog when context is auto-detected from clipboard
        Returns the context if confirmed, None if cancelled
        """
        try:
            query_preview = query[:60] + "..." if len(query) > 60 else query
            context_preview = context[:150] + "..." if len(context) > 150 else context

            mesg = (
                f"Query: \"{query_preview}\"\n\n"
                f"Context (from clipboard):\n\"{context_preview}\"\n\n"
                "Press Enter to confirm, type to replace, or Escape to cancel"
            )

            result = subprocess.run(
                ['rofi', '-dmenu', '-p', 'Confirm',
                 '-mesg', mesg,
                 '-config', str(self.simple_theme),
                 '-theme-str', 'window { width: 65%; }',
                 '-theme-str', 'entry { placeholder: "Enter to use clipboard context, or type new context..."; }'],
                input="",
                capture_output=True,
                text=True
            )

            if result.returncode != 0:
                # User cancelled
                return None

            # If user typed something, use that instead
            user_input = result.stdout.strip()
            return user_input if user_input else context

        except Exception as e:
            print(f"Error in context confirmation: {e}", file=sys.stderr)
            return None

    def show_response(self, response: str, original_query: str = "") -> None:
        """Display AI response in a floating terminal window"""
        try:
            import tempfile
            import shutil

            query_display = original_query[:100] + "..." if len(original_query) > 100 else original_query

            # Check if glow is available for markdown rendering
            has_glow = shutil.which('glow') is not None

            if has_glow:
                # Create markdown file with query header
                md_content = f"# Query: {query_display}\n\n---\n\n{response}"

                with tempfile.NamedTemporaryFile(mode='w', suffix='.md', delete=False) as f:
                    f.write(md_content)
                    temp_path = f.name

                # Use glow for beautiful markdown rendering
                style_path = Path.home() / '.local/share/glow/styles/custom.json'
                style_arg = f'-s {style_path}' if style_path.exists() else ''

                # Run glow with pager in kitty - pager handles 'q' to quit
                subprocess.Popen(
                    ['kitty', '--class', 'ai-study-helper',
                     '--title', 'AI Study Helper',
                     'bash', '-c', f'glow {style_arg} -p "{temp_path}"; rm "{temp_path}"'],
                )
            else:
                # Fallback: Use less directly
                with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
                    f.write(response)
                    temp_path = f.name

                subprocess.Popen(
                    ['kitty', '--class', 'ai-study-helper',
                     '--title', 'AI Study Helper',
                     'bash', '-c', f'less -R "{temp_path}"; rm "{temp_path}"'],
                )

        except Exception as e:
            print(f"Error showing response: {e}", file=sys.stderr)

    def show_error(self, title: str, message: str) -> None:
        """Show error message using rofi"""
        try:
            subprocess.run(
                ['rofi', '-e', message,
                 '-config', str(self.simple_theme)],
                capture_output=True
            )
        except Exception as e:
            print(f"Error showing error message: {e}", file=sys.stderr)


class ResponseCache:
    """Simple file-based cache to avoid repeated API calls"""

    def __init__(self, cache_duration_hours: int = 24):
        self.cache_dir = Path.home() / ".cache" / "ai-study-helper"
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.cache_duration = timedelta(hours=cache_duration_hours)

    def _get_cache_key(self, text: str, context: str = "") -> str:
        """Generate unique key for text+context combination"""
        combined = f"{text}|{context}"
        return hashlib.sha256(combined.encode()).hexdigest()

    def get(self, text: str, context: str = "") -> Optional[str]:
        """Retrieve cached response if still valid"""
        key = self._get_cache_key(text, context)
        cache_file = self.cache_dir / f"{key}.json"

        if not cache_file.exists():
            return None

        try:
            with open(cache_file) as f:
                data = json.load(f)

            # Check if expired
            cached_time = datetime.fromisoformat(data['timestamp'])
            if datetime.now() - cached_time > self.cache_duration:
                cache_file.unlink()
                return None

            return data['response']
        except Exception:
            return None

    def set(self, text: str, response: str, context: str = "") -> None:
        """Cache a response"""
        key = self._get_cache_key(text, context)
        cache_file = self.cache_dir / f"{key}.json"

        try:
            with open(cache_file, 'w') as f:
                json.dump({
                    'response': response,
                    'timestamp': datetime.now().isoformat(),
                    'query': text,
                    'context': context
                }, f)
        except Exception as e:
            print(f"Warning: Failed to cache response: {e}", file=sys.stderr)


class GeminiAPI:
    """Google Gemini API client with error handling"""

    def __init__(self, api_key: str, model: str, max_tokens: int, timeout: int):
        self.api_key = api_key
        self.model = model
        self.max_tokens = max_tokens
        self.timeout = timeout

    def explain_text(self, text: str, context: str = "", template_key: str = "explain") -> Tuple[bool, Optional[str], Optional[str]]:
        """
        Send text explanation request to Gemini
        Returns: (success: bool, response: str or None, error: str or None)
        """
        # Build API URL with key as query parameter (using v1beta endpoint)
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{self.model}:generateContent?key={self.api_key}"

        headers = {
            "content-type": "application/json"
        }

        # Get the prompt template
        template = PROMPT_TEMPLATES.get(template_key, PROMPT_TEMPLATES["explain"])

        # Build context line if context is provided
        context_line = f"Context: {context}\n\n" if context and context != text else ""

        # Build prompt from template
        prompt = template["prompt"].format(query=text, context_line=context_line)

        # Adjust max tokens based on template
        token_multiplier = template.get("token_multiplier", 1.0)
        adjusted_max_tokens = int(self.max_tokens * token_multiplier)

        # Gemini API request format
        payload = {
            "contents": [{
                "parts": [{
                    "text": prompt
                }]
            }],
            "generationConfig": {
                "maxOutputTokens": adjusted_max_tokens,
                "temperature": 0.7
            }
        }

        try:
            response = requests.post(
                url,
                headers=headers,
                json=payload,
                timeout=self.timeout
            )
            response.raise_for_status()

            response_data = response.json()

            # Extract text from Gemini response format
            if 'candidates' in response_data and len(response_data['candidates']) > 0:
                candidate = response_data['candidates'][0]
                if 'content' in candidate and 'parts' in candidate['content']:
                    ai_response = candidate['content']['parts'][0]['text']
                    return (True, ai_response, None)

            return (False, None, "Invalid response format from API")

        except requests.exceptions.Timeout:
            return (False, None, "Request timed out. Please check your connection and try again.")
        except requests.exceptions.RequestException as e:
            if hasattr(e, 'response') and e.response is not None:
                try:
                    error_data = e.response.json()
                    error_msg = error_data.get('error', {}).get('message', str(e))
                    return (False, None, f"API Error: {error_msg}")
                except:
                    return (False, None, f"Network error: {str(e)}")
            return (False, None, f"Network error: {str(e)}")
        except Exception as e:
            return (False, None, f"Unexpected error: {str(e)}")


def notify(title: str, message: str, urgency: str = "low") -> None:
    """Send notification"""
    try:
        subprocess.run([
            'notify-send', '-u', urgency, '-h', 'int:transient:1',
            title, message
        ], check=False)
    except:
        pass


def save_to_history(history_dir: Path, query: str, context: str, template: str, response: str) -> None:
    """Save query and response to history for later browsing"""
    try:
        timestamp = datetime.now()
        filename = timestamp.strftime("%Y%m%d_%H%M%S") + ".json"
        history_file = history_dir / filename

        history_entry = {
            "timestamp": timestamp.isoformat(),
            "query": query,
            "context": context,
            "template": template,
            "response": response
        }

        with open(history_file, 'w') as f:
            json.dump(history_entry, f, indent=2)

    except Exception as e:
        print(f"Warning: Failed to save to history: {e}", file=sys.stderr)


def browse_history(config_mgr: ConfigManager, rofi: 'RofiInterface') -> None:
    """Browse past queries and responses"""
    history_dir = config_mgr.history_dir

    # Get all history files, sorted by date (newest first)
    history_files = sorted(history_dir.glob("*.json"), reverse=True)

    if not history_files:
        rofi.show_error("History", "No history entries found yet.")
        return

    # Build menu items
    menu_items = []
    entries = []

    for hf in history_files[:50]:  # Limit to last 50 entries
        try:
            with open(hf) as f:
                entry = json.load(f)
                entries.append(entry)

                # Format: date | template | query preview
                ts = datetime.fromisoformat(entry['timestamp'])
                date_str = ts.strftime("%m/%d %H:%M")
                template_icon = PROMPT_TEMPLATES.get(entry['template'], {}).get('icon', '')
                query_preview = entry['query'][:40] + "..." if len(entry['query']) > 40 else entry['query']
                menu_items.append(f"{date_str} {template_icon} {query_preview}")
        except Exception:
            continue

    if not menu_items:
        rofi.show_error("History", "Could not load history entries.")
        return

    # Show rofi menu
    try:
        result = subprocess.run(
            ['rofi', '-dmenu', '-p', 'History',
             '-mesg', 'Select an entry to view',
             '-config', str(rofi.simple_theme),
             '-theme-str', 'window { width: 60%; }',
             '-theme-str', 'listview { lines: 15; }',
             '-i'],  # Case insensitive
            input="\n".join(menu_items),
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            return

        # Find selected entry
        selected = result.stdout.strip()
        for i, item in enumerate(menu_items):
            if item == selected:
                entry = entries[i]
                # Build full content with query, context, and response
                template_name = PROMPT_TEMPLATES.get(entry.get('template', 'explain'), {}).get('name', 'Explain')
                full_content = f"# Query\n\n{entry['query']}\n\n"
                if entry.get('context') and entry['context'] != entry['query']:
                    full_content += f"## Context\n\n{entry['context']}\n\n"
                full_content += f"---\n\n## Response ({template_name})\n\n{entry['response']}"
                rofi.show_response(full_content, "")
                return

    except Exception as e:
        print(f"Error browsing history: {e}", file=sys.stderr)


def main():
    """Main application logic"""
    # Exit codes
    EXIT_SUCCESS = 0
    EXIT_NO_API_KEY = 1
    EXIT_NETWORK_ERROR = 2
    EXIT_CANCELLED = 3
    EXIT_INVALID_INPUT = 4

    # Check for special modes
    if len(sys.argv) >= 2 and sys.argv[1] == "--history":
        config_mgr = ConfigManager()
        rofi = RofiInterface(config_mgr.config_dir)
        browse_history(config_mgr, rofi)
        sys.exit(EXIT_SUCCESS)

    # Get input text from command line arguments
    # arg1: query (the term to explain)
    # arg2: context (optional - the surrounding paragraph)
    if len(sys.argv) < 2:
        print("Error: No text provided", file=sys.stderr)
        notify("AI Study Helper", "No text provided", "critical")
        sys.exit(EXIT_INVALID_INPUT)

    query = sys.argv[1].strip()
    # Context from clipboard (passed by bash wrapper)
    clipboard_context = sys.argv[2].strip() if len(sys.argv) > 2 else ""

    if not query:
        notify("AI Study Helper", "Empty input", "critical")
        sys.exit(EXIT_INVALID_INPUT)

    # Initialize components
    config_mgr = ConfigManager()
    rofi = RofiInterface(config_mgr.config_dir)
    cache = ResponseCache(config_mgr.config['cache_duration_hours'])

    # Check for API key
    api_key = config_mgr.get_api_key()
    if not api_key:
        notify("AI Study Helper", "No API key found. Setting up...", "normal")
        if not config_mgr.setup_api_key():
            rofi.show_error("API Key Required",
                          "No API key configured. Please set up your Google Gemini API key.\n\n" +
                          "Get one at: https://aistudio.google.com/app/apikey")
            sys.exit(EXIT_NO_API_KEY)
        api_key = config_mgr.get_api_key()
        if not api_key:
            sys.exit(EXIT_NO_API_KEY)

    # Determine context - either from clipboard or prompt user
    if clipboard_context:
        # Context was provided from clipboard - show confirmation dialog
        context = rofi.show_context_confirmation(query, clipboard_context)
    else:
        # No context from clipboard - show editor for manual input
        context = rofi.show_context_editor(query)

    if context is None:
        # User cancelled
        sys.exit(EXIT_CANCELLED)

    # Show template selector
    template_key = rofi.show_template_selector(query)
    if template_key is None:
        sys.exit(EXIT_CANCELLED)

    # Check cache first (include template in cache key)
    cache_key = f"{query}|{template_key}"
    cached_response = cache.get(cache_key, context)
    if cached_response:
        notify("AI Study Helper", "Retrieved from cache", "low")
        rofi.show_response(cached_response, query)
        sys.exit(EXIT_SUCCESS)

    # Initialize API client
    api = GeminiAPI(
        api_key=api_key,
        model=config_mgr.config['model'],
        max_tokens=config_mgr.config['max_tokens'],
        timeout=config_mgr.config['api_timeout']
    )

    # Show loading notification
    template_name = PROMPT_TEMPLATES[template_key]["name"]
    notify("AI Study Helper", f"{template_name}: {query[:40]}...", "low")

    # Make API request
    success, response, error = api.explain_text(query, context, template_key)

    if not success:
        notify("AI Study Helper", f"Error: {error}", "critical")
        rofi.show_error("API Error", error or "Unknown error occurred")
        sys.exit(EXIT_NETWORK_ERROR)

    # Cache the response
    cache.set(cache_key, response, context)

    # Save to history
    save_to_history(config_mgr.history_dir, query, context, template_key, response)

    # Show response
    rofi.show_response(response, query)

    sys.exit(EXIT_SUCCESS)


if __name__ == "__main__":
    main()
