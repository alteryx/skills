# Alteryx Formula Function Reference

All potential formula functions and operators are contained in the following sections.

## Conditional

Conditional functions let you perform an action or calculation using an IF statement.

- `IF c THEN t ELSE f ENDIF`: Returns t if the condition c is true, else returns f.
- `IF c THEN t ELSEIF c2 THEN t2 ELSE f ENDIF`: Returns t if the first condition c is true, else returns t2 if the second condition c2 is true, else returns f.
- `IIF(bool, x, y)`: Returns x if bool is true, else returns y.
- `Switch(Value,Default,Case1,Result1,...,CaseN,ResultN)`: Compares a value against a list of cases and returns the corresponding result.

## String

String functions perform operations on text data. String functions can cleanse data, convert data to a different format or case, compute metrics about the data, or perform other manipulations.

- `Contains(String, Target, CaseInsensitive=1)`: Checks if String contains Target.
- `CountWords(string)`: Counts words separated by space.
- `DecomposeUnicodeForMatch(String)`: Removes accents and converts to lowercase narrow form.
- `EndsWith(String, Target, CaseInsensitive=1)`: Checks if String ends with Target.
- `FindNth(Initial String, Target, Instance)`: Finds nth occurrence of Target.
- `FindString(String,Target)`: Returns position of Target in String.
- `GetLeft(String, Delimiter)`: Returns left side before Delimiter.
- `GetPart(String, Delimiter, Index)`: Returns substring at Index.
- `GetRight(String, Delimiter)`: Returns right side after Delimiter.
- `GetWord(string, n)`: Returns nth word (0-based).
- `Left(String, len)`: Returns first len characters.
- `Length(String)`: Returns length of string.
- `LowerCase(String)`: Converts to lowercase.
- `MD5_ASCII(String)`: MD5 hash of ASCII string.
- `MD5_UNICODE(String)`: MD5 hash of UTF-16 string.
- `MD5_UTF8(String)`: MD5 hash of UTF-8 string.
- `PadLeft(String, len, char)`: Pads left to len.
- `PadRight(String, len, char)`: Pads right to len.
- `REGEX_CountMatches(String,pattern,icase)`: Count regex matches.
- `REGEX_Match(String,pattern,icase)`: Tests full regex match.
- `REGEX_Replace(String, pattern, replace, icase)`: Regex find/replace.
- `Replace(String, Target, Replacement)`: Replaces Target with Replacement.
- `ReplaceChar(String, y, z)`: Replaces characters y with z.
- `ReplaceFirst(String, Target, Replacement)`: Replaces first occurrence.
- `ReverseString(String)`: Reverses string.
- `Right(String, len)`: Returns last len characters.
- `StartsWith(String, Target, CaseInsensitive=1)`: Checks if String starts with Target.
- `STRCSPN(String, y)`: Returns length until first occurrence of y chars.
- `StripQuotes(String)`: Removes surrounding quotes.
- `STRSPN(String, y)`: Returns length of initial segment of chars in y.
- `Substring(String, start, length)`: Returns substring.
- `TitleCase(String)`: Converts to title case.
- `Trim(String, y)`: Trims y chars from both ends (default whitespace).
- `TrimLeft(String, y)`: Trims from start.
- `TrimRight(String, y)`: Trims from end.
- `Uppercase(String)`: Converts to uppercase.
- `UuidCreate()`: Creates a unique identifier.

## DateTime

DateTime functions perform an action or calculation on a date and time value.

- `DateTimeAdd(dt,i,u)`: Adds a specific interval to a date-time value.
- `DateTimeDay(dt)`: Returns the numeric value for the day of the month.
- `DateTimeDiff(dt1,dt2,u)`: Returns the difference between two dates as an integer.
- `DateTimeFirstOfMonth()`: Returns the first day of the month, at midnight.
- `DateTimeFormat(dt,f,[l],[tz])`: Converts date-time data from ISO format to another specified format.
- `DateTimeHour(dt)`: Returns the hour portion of the time.
- `DateTimeLastOfMonth()`: Returns the last day of the current month (23:59:59).
- `DateTimeMinutes(dt)`: Returns the minutes portion of the time.
- `DateTimeMonth(dt)`: Returns the numeric value for the month.
- `DateTimeNow([tz])`: Returns the current date and time, including seconds.
- `DateTimeNowPrecise(digits,[tz])`: Returns the current date and time with fractional seconds.
- `DateTimeParse(string,f,[l],[tzName])`: Converts a date string to standard format.
- `DateTimeQuarter(dt, [Q1 Start])`: Returns the quarter of the year.
- `DateTimeSeconds(dt)`: Returns the seconds portion of the time.
- `DateTimeStart()`: Returns the date/time when the workflow started.
- `DateTimeToday()`: Returns today’s date.
- `DateTimeToLocal(dt,[tz])`: Converts UTC date-time to local time zone.
- `DateTimeToUTC(dt,[tz])`: Converts date-time to UTC.
- `DateTimeTrim(dt,t)`: Removes unwanted portions of a date-time.
- `DateTimeWeekNum(dt, [StartOfWeek])`: Returns the week number of the year.
- `DateTimeWorkDays(dt1, dt2, [StartofWeek])`: Returns number of working days between two dates.
- `DateTimeYear(dt)`: Returns the numeric value for the year.
- `ToDate(x)`: Converts a string, number, or date-time to a date.
- `ToDateTime(x)`: Converts a string, number, or date to a date-time.

## Operators

An operator is a character that represents an action. Arithmetic operators can perform mathematical calculations and boolean operators work with true and false values.

- `/* Comment */`: Block comment.
- `// Comment`: Single-line comment.
- `&&`: Boolean AND operator.
- `AND`: Boolean AND keyword.
- `!`: Boolean NOT operator.
- `NOT`: Boolean NOT keyword.
- `OR`: Boolean OR keyword.
- `||`: Boolean OR operator.
- `=`: Equal to.
- `==`: Equal to.
- `>`: Greater than.
- `>=`: Greater than or equal.
- `<`: Less than.
- `<=`: Less than or equal.
- `!=`: Not equal to.
- `+`: Adds numbers, concatenates strings, or unions spatial objects.
- `-`: Subtracts numbers or removes one spatial object from another.
- `*`: Multiplies numbers.
- `/`: Divides numbers; always returns a double.
- `value IN (...)`: Returns True if value is in list.
- `value NOT IN (...)`: Returns True if value not in list.

### Order of Precedence

This table shows the established order of operator groups. Operations within a group bind left to right.

| Order | Operators |
|--------|------------|
| 1 | `*`, `/` |
| 2 | `+`, `-` |
| 3 | `<=`, `<`, `>=`, `>`, `IN`, `NOT` |
| 4 | `=`, `!=` |
| 5 | `&&`, `AND`, `||`, `OR` |

## Conversion

Conversion functions convert numbers to strings or strings to numbers.

- `BinToInt(s)`: Converts the binary string s to an integer (limited to 53 bits).
- `CharFromInt(x)`: Returns the Unicode character that matches the input number x.
- `CharToInt(s)`: Returns the number that matches the input Unicode character s.
- `ConvertFromCodePage(s, codePage)`: Translates text from a code page to Unicode.
- `ConvertToCodePage(s, codePage)`: Translates text from Unicode encoding to a specific code page.
- `HexToNumber(x)`: Converts a HEX string to a number (limited to 53 bits).
- `IntToBin(x)`: Converts x to a binary string.
- `IntToHex(x)`: Converts x to a hexadecimal string.
- `ToDegrees(x)`: Converts a numeric radian value (x) to degrees.
- `ToNumber(x, [bIgnoreErrors], [keepNulls], [decimalSeparator])`: Converts a string (x) to a number.
- `ToRadians(x)`: Converts a numeric degree value (x) to radians.
- `ToString(x, numDec, [addThousandsSeparator], [decimalSeparator])`: Converts a numeric parameter (x) to a string using numDec decimal places.
- `UnicodeNormalize(String, Form)`: Converts text data into a standardized Unicode form.

## Math

Math functions perform mathematical calculations.

- `ABS(x)`: Returns absolute value of x.
- `ACOS(x)`: Returns arccosine.
- `ASIN(x)`: Returns arcsine.
- `ATAN(x)`: Returns arctangent.
- `ATAN2(y, x)`: Returns arctangent of y/x.
- `Average(n1, ...)`: Average of a list of numbers.
- `AverageNonNull(n1, ...)`: Average excluding nulls.
- `CEIL(x, [mult])`: Rounds up to nearest multiple.
- `COS(x)`: Cosine of x.
- `COSH(x)`: Hyperbolic cosine.
- `DISTANCE(from_Lat,from_Lon,to_Lat,to_Lon)`: Distance between coordinates.
- `EXP(x)`: e^x.
- `FACTORIAL(x)`: Factorial of x.
- `FLOOR(x, [mult])`: Rounds down to nearest multiple.
- `LOG(x)`: Natural logarithm.
- `LOG10(x)`: Base-10 logarithm.
- `Median(...)`: Median of values.
- `Mod(n,d)`: Modulo operation.
- `PI()`: Constant π.
- `POW(x,e)`: x raised to e.
- `RAND()`: Random number [0,1).
- `RandInt(n)`: Random integer [0,n].
- `Round(x,mult)`: Rounds x to nearest multiple.
- `SIN(x)`: Sine.
- `SINH(x)`: Hyperbolic sine.
- `SmartRound(x)`: Dynamic rounding based on size.
- `SQRT(x)`: Square root.
- `TAN(x)`: Tangent.
- `TANH(x)`: Hyperbolic tangent.

## File

File functions build file paths, check to see if a file exists, or extract a part of a file path.

- `FileAddPaths(Path1, Path2)`: Adds two file path parts, ensuring one backslash between them.
- `FileExists(Path)`: Returns True if the file exists, else False.
- `FileGetDir(Path)`: Returns the directory portion of the path.
- `FileGetExt(Path)`: Returns the file extension.
- `FileGetFileName(Path)`: Returns the file name without extension.

## Finance

Finance functions apply financial algorithms or mathematical calculations.

- `FinanceCAGR(BeginningValue, EndingValue, NumYears)`: Calculates Compound Annual Growth Rate.
- `FinanceEffectiveRate(NominalRate, PaymentsPerYear)`: Calculates Effective Annual Interest Rate.
- `FinanceFV(Rate, NumPayments, PaymentAmount, PresentValue, PayAtPeriodBegin)`: Calculates Future Value.
- `FinanceFVSchedule(Principle, Year1Rate, Year2Rate)`: Calculates Future Value Schedule.
- `FinanceIRR(Value1, Value2)`: Calculates Internal Rate of Return.
- `FinanceMIRR(FinanceRate, ReinvestRate, Value1, Value2)`: Calculates Modified Internal Rate of Return.
- `FinanceMXIRR(FinanceRate, ReinvestRate, Value1, Date1, Value2, Date2)`: Modified IRR with dates.
- `FinanceNominalRate(EffectiveRate, PaymentsPerYear)`: Calculates Nominal Annual Interest Rate.
- `FinanceNPER(Rate, PaymentAmount, PresentValue, FutureValue, PayAtPeriodBegin)`: Number of periods.
- `FinanceNPV(Rate, Value1, Value2)`: Net Present Value.
- `FinancePMT(Rate, NumPayments, PresentValue, FutureValue, PayAtPeriodBegin)`: Loan payment amount.
- `FinancePV(Rate, NumPayments, PaymentAmount, FutureValue, PayAtPeriodBegin)`: Present Value.
- `FinanceRate(NumPayments, PaymentAmount, PresentValue, FutureValue, PayAtPeriodBegin)`: Interest rate per period.
- `FinanceXIRR(Value1, Date1, Value2, Date2)`: IRR with dates.
- `FinanceXNPV(Rate, Value1, Date1, Value2, Date2)`: NPV with dates.

## Bitwise

Bitwise functions operate on one or more bit patterns or binary numerals at the level of their individual bits.

- `BinaryAnd(n,m)`: Bitwise AND.
- `BinaryNot(n)`: Bitwise NOT.
- `BinaryOr(n,m)`: Bitwise OR.
- `BinaryXOr(n,m)`: Bitwise XOR.
- `ShiftLeft(n,b)`: Left shift by b bits.
- `ShiftRight(n,b)`: Right shift by b bits.

## Min/Max

Minimum or maximum functions find the smallest and largest value of a set of values.

- `BETWEEN(x, min, max)`: Tests if x is between min and max.
- `Bound(x, min, max)`: Clamps x to [min,max].
- `Max(v0, v1, ..., vn)`: Maximum value.
- `MaxIDX(v0, v1,..., vn)`: Index of maximum value.
- `Min(v0, v1,..., vn)`: Minimum value.
- `MinIDX(v0, v1,..., vn)`: Index of minimum value.

## Spatial

Spatial functions build spatial objects, analyze spatial data, and return metrics from spatial fields.

- `ST_Area(object, units)`: Area of spatial object.
- `ST_Boundary(object)`: Boundary of spatial object.
- `ST_BoundingRectangle(object, ...)`: Bounding rectangle.
- `ST_Centroid(object)`: Centroid of object.
- `ST_CentroidX(object)`: Longitude of centroid.
- `ST_CentroidY(object)`: Latitude of centroid.
- `ST_Combine(object1, object2,...)`: Combines spatial objects.
- `ST_Contains(object1,object2)`: True if object1 contains object2.
- `ST_ConvexHull(object1,...)`: Convex hull.
- `ST_CreateLine(point1, point2,...)`: Creates line from points.
- `ST_CreatePoint(x,y)`: Creates point.
- `ST_CreatePolygon(obj1, obj2,...)`: Creates polygon.
- `ST_Cut(object1,object2)`: Cuts object1 from object2.
- `ST_Dimension(object)`: Returns dimension (0=point, 1=line, 2=polygon).
- `ST_Distance(object1, object2, units)`: Distance between spatial objects.
- `ST_EndPoint(object)`: Last point of object.
- `ST_Intersection(object1, object2, ...)`: Intersection of spatial objects.
- `ST_Intersects(object1, object2, ...)`: True if objects intersect.
- `ST_InverseIntersection(object1, object2, ...)`: Inverse intersection.
- `ST_Length(object, units)`: Linear length.
- `ST_MD5(object)`: MD5 hash of spatial object.
- `ST_MaxX(object)`: Max longitude.
- `ST_MaxY(object)`: Max latitude.
- `ST_MinX(object)`: Min longitude.
- `ST_MinY(object)`: Min latitude.
- `ST_NumParts(object)`: Number of parts.
- `ST_NumPoints(object)`: Number of points.
- `ST_ObjectType(object)`: Type of spatial object.
- `ST_PointN(object, n)`: Nth point.
- `ST_RandomPoint(object)`: Random point.
- `ST_Relate(object1,object2,relation)`: True if objects satisfy DE-9IM relation.
- `ST_StartPoint(object)`: First point.
- `ST_Touches(object1, object2)`: True if objects touch.
- `ST_TouchesOrIntersects(object1, object2)`: True if touch or intersect.
- `ST_Within(object1, object2)`: True if object1 within object2.

## Specialized

These functions perform a variety of specialized actions and can be used with all data types.

- `Coalesce(v1,v2,v3,…,vn)`: Returns first non-null value.
- `EscapeXMLMetacharacters(String)`: Escapes XML metacharacters.
- `GetVal(index, v0,...vn)`: Returns value by 0-based index.
- `GetEnvironmentVariable(Name)`: Returns environment variable value.
- `Message(messageType, message, returnValue)`: Outputs message and value when condition met.
- `NULL()`: Returns Null.
- `RangeMedian(...)`: Median from aggregated ranges.
- `ReadRegistryString(Key, ValueName, DefaultValue="")`: Reads registry value.
- `Soundex(String)`: Returns Soundex code of string.
- `Soundex_Digits(String)`: Returns first 4 digits or Soundex code.
- `TOPNIDX(N, v0, v1, ..., vn)`: Index of Nth from max value.
- `UrlEncode(String)`: Legacy UTF-16 percent-encoding (use UrlEncodeUTF8 instead).
- `UrlEncodeUTF8(String)`: RFC 3986-compliant percent-encoding.

## Test

Test functions perform data comparisons. Test functions can identify the data type of a value or determine if a value exists.

- `CompareDictionary(a,b)`: Case-insensitive compare with numeric sort.
- `CompareDigits(a,b,nNumDigits)`: Compares numbers to given precision.
- `CompareEpsilon(a,b,epsilon)`: Compares floats within epsilon.
- `EqualStrings(a,b)`: Tests if strings are identical.
- `IsEmpty(v)`: True if v is NULL or empty string.
- `IsInteger(v)`: True if v can be converted to integer.
- `IsLowerCase(String)`: True if all alphabetic chars lowercase.
- `IsNull(v)`: True if v is NULL.
- `IsNumber(v)`: True if v is numeric type.
- `IsSpatialObj(v)`: True if v is spatial object.
- `IsString(v)`: True if v is string type.
- `IsUpperCase(String)`: True if all alphabetic chars uppercase.

## Null Handling

This table demonstrates how Alteryx handles Nulls. The same handling applies to numbers and strings.

| Data1 | Data2 | `>` | `<` | `==` | `!=` |
|:------|:------|:---:|:---:|:----:|:----:|
| 1 | Null | False | False | False | True |
| 0 | Null | False | False | False | True |
| Null | Null | False | False | True | False |

- `1 + Null() == Null()`: Adding a number to Null returns Null.
- `"ABC" + Null() == "ABC"`: Adding a string to Null returns the string.
- `Null() < Null()` and `Null() > Null()`: Always return False.
- `Null() <= Null()` and `Null() >= Null()`: Return True only when both sides are Null.
- Comparisons (`<`, `>`, `=`, `!=`) with Null generally return False, except `Null() == Null()` is True.
