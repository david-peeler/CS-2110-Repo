	/**
 * @file hw7.c
 * @author David Peeler
 * @brief Command-line argument & expression parsing logic
 * @date 2020-03-30
 */

// DO NOT MODIFY THE INCLUDE(s) LIST
#include <stdio.h>
#include "hw7.h"
#include "errcodes.h"

#define FALSE 0
#define TRUE 1

// One-time defined global array of expressions
struct expression arr[MAX_NUMBER_OF_EXPRESSIONS];

/**
 * @brief Convert a string containing ASCII characters (in decimal) to an int.
 *
 * @param str A null-terminated C string
 * @return int the corresponding decimal value of the passed in str
 */
int decimalStringToInt(const char *str)
{
	const char *beginningPointer = str;
	int returnValue = 0;
	int multFactor = 1;

	while(*str != '\0') {
		str++;
	}
	str--;

	while(beginningPointer <= str) {
		returnValue+=(*str - 48) * multFactor;
		multFactor*=10;
	    str--;
	}

    return returnValue;
}

/**
 * @brief Convert a string containing ASCII characters (in hex) to an int.
 *
 * @param str A null-terminated C string
 * @return int the corresponding decimal value of the passed in hexadecimal str
 */
int hexStringToInt(const char *str)
{
	const char *beginningPointer = str;
	int returnValue = 0;
	int multFactor = 1;

	while(*str != '\0') {
		str++;
	}
	str--;

	int value;
	while(beginningPointer <= str) {
		char ch = *str;
		if(ch>=65 && ch<=70) {
			value = ch - 55;
		} else if(ch>=48 && ch<=57) {
			value = ch - 48;
		}
		returnValue+= value * multFactor;
		multFactor*=16;
		str--;
	}
   return returnValue;
}

/**
 * @brief Parser algorithm for determining the result of a basic math expression.
 *
 * @param expression A null terminated expression retrieved as a command line arg
 * @param index Indicating the corresponding struct in the global struct array (for this expression) to be populated
 */
void parseExpression(const char *expression, int index) {
    int returnValue = 0;
    int isRightFlag = TRUE;
    int counter = 0;
    int expressionLength = my_strlen(expression);

	if(expressionLength > MAX_EXPRESSION_LENGTH) {																											//is our expression too long?
		arr[index].errorCode = (unsigned int)(ERR_EXPRESSION_TOO_LONG);
	} else if(expressionLength < MIN_EXPRESSION_LENGTH) {																									//is our expression too small?
        arr[index].errorCode = (unsigned int)(ERR_EXPRESSION_TOO_SMALL);
	}
	if(index >= expressionLength) {																												//we're not at the end of the expression
		isRightFlag = -1;
	}


    int operatorFlag = FALSE;
    while (*(expression + counter) != '\0' && isRightFlag == TRUE && counter < expressionLength) {													//loop through the entire expression
		if (*(expression + counter) == '-') {																									//we found a minus sign
			operatorFlag = TRUE;
		} else if(*(expression + counter) == '+') {																								//we found a plus sign
			operatorFlag = FALSE;
		} else if((int)(*(expression + counter)) == 32) {																						//we found the end of the expression
			isRightFlag = TRUE;
		} else {																																//we found some sort of number
            if (*(expression + counter) == '0') {																								//if we found a 0, we need to see if this is a hex number
                int slider = 0;
                while (*(expression + counter) == '0') {																						//seeing how long the number is
					slider++;
                    counter++;
                }
                if (*(expression + counter) != '\0') {
                    if (*(expression + counter) == 'x' && slider == 1) {																		//we found a hex number
                        counter++;
                        int numLength = 0;
                        int numFlag = FALSE;
                        while ((int)(*(expression + counter + numLength)) > 45 && numFlag == FALSE && (*(expression + counter + numLength)) != '\0') {	//if we're working with a hex number with correct digits
                            if ((int)(*(expression + counter + numLength)) > 70) {																		//seeing if the hex number is deformed
                                numFlag = TRUE;
                                isRightFlag = -1;
                                arr[index].errorCode = (unsigned int)(ERR_MALFORMED_HEX_FOUND);
                            }
                            numLength++;
                        }
                        if (numLength > 0 && numFlag == FALSE) {
                            char number[numLength];
                            my_strncpy(number, (expression + counter), numLength);
                            *(&(number[numLength - 1]) + 1) = '\0';
                            int hex = hexStringToInt(number);
                            if (operatorFlag == FALSE) {
                                returnValue = returnValue + hex;
                            } else {
                                returnValue = returnValue - hex;
                            }
                        }
                        counter = counter + numLength - 1;
                    } else if (*(expression + counter) == 'x' && slider != 1) {
                        isRightFlag = isRightFlag * -1;
                        arr[index].errorCode = (unsigned int)(ERR_MALFORMED_HEX_FOUND);
                    } else {
                        counter--;
                    }
                } else {
                    counter--;
                }
            } else {
                int numLength = 0;
                int numFlag = FALSE;
                while ((int)(*(expression + counter + numLength)) > 45 && *(expression + counter + numLength) != '\0' && numFlag == FALSE) {
                    if ((int)(*(expression + counter + numLength)) > 57) {
                        numFlag = TRUE;
                        isRightFlag = -1;
                        arr[index].errorCode = (unsigned int)(ERR_MALFORMED_HEX_FOUND);
                    }
                    numLength++;
                }
                if (numLength > 0 && numFlag == FALSE) {
                    char number[numLength];
                    my_strncpy(number, expression + counter, numLength);
                    *(&(number[numLength - 1]) + 1) = '\0';
                    int dec = decimalStringToInt(number);
                    if (operatorFlag == FALSE) {
                        returnValue = returnValue + dec;
                    } else {
                        returnValue = returnValue - dec;
                    }
                    counter = counter + numLength - 1;
                }
            }
        }
        counter++;
        //printf("\n Decimal: %d and %d", k, decimal);
    }
    if (isRightFlag == 1) {
		//All good in the hood sir
        arr[index].result = returnValue;
        arr[index].errorCode = (unsigned int)(NO_ERROR);
        my_strncpy(&(arr[index].buffer[0]), expression, expressionLength);
    } else {
		//Lets throw an error
        char errorMessage[] = ERROR_MSG;
        my_strncpy(&(arr[index].buffer[0]), &(errorMessage[0]), my_strlen(&(errorMessage[0])));
    }
}

/**
 * @brief Helper method for printing out the global array struct info
 * DO NOT MODIFY THIS METHOD AS IT IS USED FOR THE LAST STEP (PIPE).
 */
void printArrayDebug(void)
{
    // Safety check
    if (sizeof(arr) / sizeof(arr[0]) != MAX_NUMBER_OF_EXPRESSIONS)
    {
        printf("ERROR: MISMATCH ARRAY LENGTH WITH MACRO: MAX_NUMBER_OF_EXPRESSIONS.\n");
        return;
    }

    for (int i = 0; i < MAX_NUMBER_OF_EXPRESSIONS; i++)
    {
        printf("\nStruct info at index %d:\n", i);
        printf("Expression: %s\n", arr[i].buffer);
        printf("Result: %d\n", arr[i].result);
        printf("ErrorCode: %u\n", arr[i].errorCode);
        printf("---------------------\n");
    }
}

/**
 * @brief Main method, responsible for parsing command line argument and populating expression structs in the global arr
 *
 * @param argc argument count
 * @param argv argument vector (it's an array of strings)
 * @return int status code of the program termination
 */
int my_main(int argc, char const *argv[])
{
    // Initial check: We need at least 1 math expression passed in
    // ( Yes argc can possibly be zero! But we don't worry about that too much in this hw :) )
    if ((argc < 2))
    {
        printf("USAGE:   ./hw7 [-d] \"basic math expressions separated by quotation marks\"\n");
        printf("EXAMPLE: ./hw7 \"3+0x40-7+5\" \"0xA6+5000-45\"\n");
        printf("EXAMPLE FOR PRINTING OUT DEBUG INFO: ./hw7 -d \"3+0x40-7+5\" \"0xA6+5000-45\"\n");
        return 1; // Exit failure (value is implementation defined)
    } else if ((argc < 3 && argv[1][0] == '-' && argv[1][1] == 'd')) {
        printf("PROGRAM ERROR");
        return 1; // Exit failure (value is implementation defined)
    } else if (argv[1] != NULL && argv[1][0] == '-' && argv[1][1] == 'd') {
        if (argc > (MAX_NUMBER_OF_EXPRESSIONS + 2)) {
            return 1;
        }
        for (int i = 2; i < argc; i++) {
            parseExpression(&(argv[i][0]), i - 2);
        }
        arr[argc].result = 0;
        arr[argc].errorCode = 0;
        printArrayDebug();
        return 0;
    } else {
        if (argc > (MAX_NUMBER_OF_EXPRESSIONS + 1)) {
            return 1;
        }
        for (int i = 1; i < argc; i++) {
            parseExpression(&(argv[i][0]), i - 1);
        }
        arr[argc].result = 0;
        arr[argc].errorCode = 0;
        return 0;
    }
    return 0; // EXIT_SUCCESS
}
