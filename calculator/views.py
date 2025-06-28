from django.shortcuts import render
import logging

# Get a logger instance
logger = logging.getLogger(__name__)

def index(request):
    """
    The main view for the calculator.
    Handles both GET and POST requests.
    """
    result = ''
    expression = ''
    
    if request.method == 'POST':
        # Get the expression from the POST data
        expression = request.POST.get('expression', '')
        
        try:
            # IMPORTANT SECURITY NOTE:
            # eval() is a powerful function that can execute any Python code.
            # Using it on un-sanitized user input is a major security risk in a
            # real-world production application. For this educational project,
            # we are using it for simplicity. In a real app, you should parse
            # and evaluate the expression safely using a dedicated library.
            
            # Whitelist of allowed characters for the expression
            allowed_chars = "0123456789.+-*/() "
            if all(char in allowed_chars for char in expression):
                # If the expression is safe, evaluate it
                result = eval(expression)
            else:
                # If invalid characters are found, show an error
                result = 'Error: Invalid characters'

        except (SyntaxError, ZeroDivisionError, NameError, TypeError) as e:
            # Handle potential errors during evaluation
            result = f'Error: {e}'
        except Exception as e:
            # Catch any other unexpected errors
            logger.error(f"An unexpected error occurred: {e}")
            result = 'Error: An unexpected error occurred'
            
    # Prepare the context to be passed to the template
    context = {
        'result': result,
        'expression': expression
    }
    
    # Render the HTML template with the context
    return render(request, 'calculator/index.html', context)
