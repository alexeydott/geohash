unit geohash;

interface

uses System.Classes, System.SysUtils, System.Character, System.Math;

type
  TCardinalDirectionType = (cdtNorth = 0,
    cdtEast = 1, cdtWest = 2, cdtSouth = 3);

  TGeoHash = record
  strict private
  const
    /// <summary>
    ///   maximum length for geohashes
    /// </summary>
    MAX_HASH_LENGTH = 22;
    /// <summary>
    ///   Default maximum number of hashes for covering a bounding box.
    /// </summary>
    DEFAULT_HASH_LENGTH = 12;
    /// <summary>
    ///   The characters used in base 32 representations.
    /// </summary>
    BASE32_ENCODE_TABLE: array [0..31] of Char = (
    '0',  '1',  '2',  '3',  '4',
    '5',  '6',  '7',  '8',  '9',
    'b',  'c',  'd',  'e',  'f',
    'g',  'h',  'j',  'k',  'm',unit geohash;

interface

uses System.Types, System.SysUtils, System.Character, System.Math;

type
  TCardinalDirectionType = (cdtNorth = 0, cdtEast = 1, cdtWest = 2, cdtSouth = 3);

  TGeoHash = record
  strict private
  const
    /// <summary>
    ///   maximum length for geohashes
    /// </summary>
    MAX_HASH_LENGTH = 22;
    /// <summary>
    ///   Default maximum number of hashes for covering a bounding box.
    /// </summary>
    DEFAULT_HASH_LENGTH = 12;

    BIT_DIV = 5;
    MAX_BIT = MAX_HASH_LENGTH * BIT_DIV;
    /// <summary>
    ///   The characters used in base 32 representations.
    /// </summary>
    BASE32_ENCODE_TABLE: array [0..31] of Char = (
    '0',  '1',  '2',  '3',  '4',
    '5',  '6',  '7',  '8',  '9',
    'b',  'c',  'd',  'e',  'f',
    'g',  'h',  'j',  'k',  'm',
    'n',  'p',  'q',  'r',  's',
    't',  'u',  'v',  'w',
    'x',  'y',  'z');
    /// <summary>
    ///   The characters used in base 32 representations.
    /// </summary>
    BASE32_DECODE_TABLE: array[0..42] of Integer = (
    {0}   0, {1}   1, {2}   2, {3}   3, {4}   4,
    {5}   5, {6}   6, {7}   7, {8}   8, {9}   9,
    {:}  -1, {;}  -1, {<}  -1, {=}  -1, {>}  -1,
    {?}  -1, {@}  -1, {A}  -1, {B}  10, {C}  11,
    {D}  12, {E}  13, {F}  14, {G}  15, {H}  16,
    {I}  -1, {J}  17, {K}  18, {L}  -1, {M}  19,
    {N}  20, {O}  -1, {P}  21, {Q}  22, {R}  23,
    {S}  24, {T}  25, {U}  26, {V}  27, {W}  28,
    {X}  29, {Y}  30, {Z}  31
    );
    /// <summary>
    ///   Table for lookup for neighbouring hashes.
    /// </summary>
    NEIGHBORS_TABLE: array[0..7] of array[0..31] of Char = (
    // north even
    ('p','0','r','2','1','4','3','6','x','8','z','b','9','d','c','f','5','h','7','k','j','n','m','q','e','s','g','u','t','w','v','y'),
    // north odd
    ('b','c','0','1','f','g','4','5','2','3','8','9','6','7','d','e','u','v','h','j','y','z','n','p','k','m','s','t','q','r','w','x'),
    // east even
    ('b','c','0','1','f','g','4','5','2','3','8','9','6','7','d','e','u','v','h','j','y','z','n','p','k','m','s','t','q','r','w','x'),
    // east odd
    ('p','0','r','2','1','4','3','6','x','8','z','b','9','d','c','f','5','h','7','k','j','n','m','q','e','s','g','u','t','w','v','y'),
    // west even
    ('2','3','8','9','6','7','d','e','b','c','0','1','f','g','4','5','k','m','s','t','q','r','w','x','u','v','h','j','y','z','n','p'),
    // west odd
    ('1','4','3','6','5','h','7','k','9','d','c','f','e','s','g','u','j','n','m','q','p','0','r','2','t','w','v','y','x','8','z','b'),
    // south even
    ('1','4','3','6','5','h','7','k','9','d','c','f','e','s','g','u','j','n','m','q','p','0','r','2','t','w','v','y','x','8','z','b'),
    // south odd
    ('2','3','8','9','6','7','d','e','b','c','0','1','f','g','4','5','k','m','s','t','q','r','w','x','u','v','h','j','y','z','n','p')
    );
    /// <summary>
    ///   Table for lookup for hash borders.
    /// </summary>
    BORDERS_TABLE: array[0..7] of array[0..7] of Char = (
    // north even
      ('p','r','x','z',#0,#0,#0,#0),
    // north odd
      ('b','c','f','g','u','v','y','z'),
    // east even
      ('b','c','f','g','u','v','y','z'),
    // east odd
      ('p','r','x','z',#0,#0,#0,#0),
    // west even
      ('0','1','4','5','h','j','n','p'),
    // west odd
      ('0','2','8','b',#0,#0,#0,#0),
    // south even
      ('0','2','8','b',#0,#0,#0,#0),
    // south odd
      ('0','1','4','5','h','j','n','p')
    );

    private
    class var
      HASH_WIDTHS: array[0..MAX_HASH_LENGTH-1] of Double;
      HASH_HEIGHTS: array[0..MAX_HASH_LENGTH-1] of Double;
      HashSizesCalculated: Boolean;
    // Returns the width and height in degrees of the region represented by a geohash string length
    class procedure CalculateHashSizes(); static;

  type
    TGeoHashRange = record
      Min: Double;
      Max: Double;
    public
      function Size: Double; inline;
      function Center: Double; inline;
    end;

    TGeoHashEnvelope = record
      Latitude: TGeoHashRange;
      Longitude: TGeoHashRange;
    public
      class function InitialRange: TGeoHashEnvelope; static; inline;
      class function SwapRanges(const Source: TGeoHashEnvelope): TGeoHashEnvelope; static; inline;
    end;

  /// <summary>
  ///   Refines range by a factor or 2 in either the 0 or 1 ordinate.
  /// </summary>
    class procedure RefineRange(var Range: TGeoHashRange; Bits: NativeInt; Offset: NativeInt); static; inline;
    class procedure SetBit(AValue: Double; AOffset: NativeInt; var VRange: TGeoHashRange; var VBits: NativeInt; var VMid: Double); static; inline;
    class function ValidLatitude(const Value: Double): Boolean; static; inline;
    class function ValidLongitude(const Value: Double): Boolean; static; inline;

    class function HeightDegrees(n: Integer): Double; static; inline;
    class function WidthDegrees(n: Integer): Double; static; inline;
  public
    /// <summary>
    ///   Returns the adjacent hash for given direction
    /// </summary>
    /// <param name="Hash">
    ///   string hash relative to which the adjacent is returned
    /// </param>
    /// <param name="Direction">
    ///   direction relative to hash for which the adjacent is returned
    /// </param>
    /// <returns>
    ///   hash of adjacent hash
    /// </returns>
    class function Adjacent(const Hash: string; Direction: TCardinalDirectionType): string; static; inline;
    /// <summary>
    ///   Returns a latitude longitude pair as the centre of the given geohash
    ///   and hash envelope size.
    /// </summary>
    class function DecodeExactly(Value: PChar; out Latitude, Longitude,LatitudeRange, LongitudeRange: Double): Boolean; overload; static; inline;
    /// <summary>
    ///   Returns a latitude longitude pair as the centre of the given geohash
    ///   and hash envelope size.
    /// </summary>
    class function DecodeExactly(const Value: string; out Latitude, Longitude, LatitudeError, LongitudeError: Double): Boolean; overload; static; inline;
    /// <summary>
    ///   Returns a latitude,longitude pair as the centre of the given geohash.
    /// </summary>
    class function Decode(const Value: string; out Latitude, Longitude: Double): Boolean; overload; static; inline;
    /// <summary>
    ///   Returns a latitude,longitude pair as the centre of the given geohash.
    /// </summary>
    class function Decode(const Value: PChar; out Latitude, Longitude: Double): Boolean; overload; static; inline;
    /// <summary>
    ///   Returns the maximum length in degrees for hash given size. <br />
    /// </summary>
    class function Dimentions(const HashLength: NativeInt; out LatitudeRange, LongitudeRange: Double): Boolean; overload; static; inline;
    /// <summary>
    ///   Returns the maximum length bounding box in meters for given hash
    ///   string. <br />
    /// </summary>
    class function Dimentions(const Hash: string; out Meters: Double): Boolean; overload; static;
    /// <summary>
    ///   Make a geohash given length for the given Latitude and
    ///   Longitude.
    /// </summary>
    /// <param name="Latitude">
    ///   latitude
    /// </param>
    /// <param name="Longitude">
    ///   longitude <br />
    /// </param>
    /// <param name="HashLength">
    ///   length of hash string
    /// </param>
    /// <param name="VResult">
    ///   hash string
    /// </param>
    /// <returns>
    ///   true if success
    /// </returns>
    class function Encode(const Latitude, Longitude: Double; HashLength: NativeUInt; out VResult: string): Boolean; overload; static; inline;
    /// <summary>
    ///   Returns a geohash of given length for the given latitude and
    ///   longitude <br />
    /// </summary>
    /// <param name="Latitude">
    ///   latitude
    /// </param>
    /// <param name="Longitude">
    ///   longitude <br />
    /// </param>
    /// <param name="HashLength">
    ///   length of hash string
    /// </param>
    /// <returns>
    ///   hashstring
    /// </returns>
    class function Encode(const Latitude, Longitude: Double; HashLength: NativeUInt = 12): string; overload; static; inline;
    class function Join(const Hash1,Hash2: string): string; static; inline;
    /// <summary>
    ///   Returns true if and only if the bounding box corresponding to the
    ///   hash contains the given lat and long.
    /// </summary>
    /// <param name="Hash">
    ///   hash to test containment in
    /// </param>
    /// <param name="Longitude">
    ///   longitude
    /// </param>
    /// <param name="Latitude">
    ///   latitude
    /// </param>
    /// <param name="Epsilon">
    ///   within epsilon
    /// </param>
    class function Contains(const Hash: string; const Longitude, Latitude: Double; const Epsilon: Double = 0): Boolean; static; inline;
    /// <summary>
    ///   Returns the max length of hash that covers given envelope in meters
    /// </summary>
    class function HashLength(const Meters: Double): NativeInt; overload; static; inline;
    /// <summary>
    ///   Returns the max length of hash that covers given envelope
    /// </summary>
    class function HashLength(const Latitude1, Longitude1, Latitude2, Longitude2: Double): NativeInt; overload; static; inline;
    /// <summary>
    ///   validate hash string
    /// </summary>
    class function Verify(const Value: PChar): Boolean; overload; static; inline;
    /// <summary>
    ///   validate hash string
    /// </summary>
    class function Verify(const Value: string): Boolean; overload; static; inline;
  end;

  TGeoHashNeighbors = record
    North,
    NorthEast,
    East,
    SouthEast,
    South,
    West,
    SouthWest,
    NorthWest: string;
  strict private
    procedure Clear();
  public
    constructor Create(const Hash: string); overload;
    class function CreateByHash(const Hash: string): TGeoHashNeighbors; static; inline;
    function ToString(Delimiter: string): string;
  end;


implementation

{ TGeoHash }

class function TGeoHash.Dimentions(const HashLength: NativeInt;
  out LatitudeRange, LongitudeRange: Double): Boolean;
var
  I, J: NativeInt;
begin
  Result := (HashLength > 0);
  if not Result then
    Exit;

  LongitudeRange := 360;
  LatitudeRange := 180;

	J := (HashLength * 5) div 2;
  for I := 0 to J -1 do
    LatitudeRange := LatitudeRange * 0.5;

  J := (HashLength * 5) div (2 + IfThen(Boolean(HashLength mod 2),1,0));
  for I := 0 to J -1 do
    LongitudeRange := LongitudeRange * 0.5;
end;

class procedure TGeoHash.CalculateHashSizes;
var
  i: Integer;
begin
  if not HashSizesCalculated then
  begin
    for i := 0 to MAX_HASH_LENGTH -1 do
    begin
      if i mod 2 = 0 then
      begin
        HASH_HEIGHTS[i] := 0;
        HASH_WIDTHS[i] := -1;
      end
      else
      begin
        HASH_HEIGHTS[i] := -0.5;
        HASH_WIDTHS[i] := -0.5;
      end;

      HASH_WIDTHS[i] := 180 / power(2, 2.5 * i + HASH_WIDTHS[i]);
      HASH_HEIGHTS[i] := 180 / power(2, 2.5 * i + HASH_HEIGHTS[i]);
    end;

    hashSizescalculated := true;
  end;
end;

class function TGeoHash.Contains(const Hash: string; const Longitude, Latitude: Double; const Epsilon: Double): Boolean;
var
  HashLength: Integer;
  CenterLat,CenterLon, LatRange,LonRange: Double;
begin
  HashLength := Length(Hash);
  Result := HashLength > 0;
  if not Result then
    Exit;

  Result := Dimentions(HashLength,LatRange, LonRange) and Decode(Hash, CenterLat, CenterLon);
  if not Result then
    Exit;

  Result := (CompareValue(CenterLat - Latitude,LatRange * 0.5, Epsilon) <> GreaterThanValue) and
            (CompareValue(CenterLon - Longitude,LonRange * 0.5, Epsilon) <> GreaterThanValue);

//  latRange := HeightDegrees(HashLength) * 0.5;
//  lonRange := WidthDegrees(HashLength) * 0.5;

end;

class function TGeoHash.Decode(const Value: PChar; out Latitude, Longitude: Double): Boolean;
var
  ErrLat,ErrLon: Double;
begin
  Result := DecodeExactly(Value,Latitude,Longitude,ErrLat,ErrLon);

end;

class function TGeoHash.DecodeExactly(Value: PChar; out Latitude, Longitude,
    LatitudeRange, LongitudeRange: Double): Boolean;
var
  I,CharCode: Integer;
  ValueLength: NativeInt;
  C: Char;
  Env: TGeoHashEnvelope;
begin
  Latitude := NaN;
  Longitude := NaN;
  LatitudeRange := NaN;
  LongitudeRange := NaN;


  ValueLength := StrLen(Value);
  Result := ValueLength > 0;
  if not Result then
    Exit;

  Env := TGeoHashEnvelope.InitialRange;
  for I := 0 to ValueLength -1 do
  begin
    C := Value^.ToUpper;
    CharCode := Ord(C);

    Result := (CharCode > 47); // 2F
    if Result then
    begin
      Dec(CharCode, 48);// $30

      Result := (CharCode > -1) and (CharCode < 69); // $43

      if Result then
      begin
        CharCode := BASE32_DECODE_TABLE[CharCode];
        Result := CharCode > -1;
        if Result then
        begin
          RefineRange(Env.Longitude, CharCode, 16);
          RefineRange(Env.Latitude, CharCode, 8);
          RefineRange(Env.Longitude, CharCode, 4);
          RefineRange(Env.Latitude, CharCode, 2);
          RefineRange(Env.Longitude, CharCode, 1);

          Env := TGeoHashEnvelope.SwapRanges(Env);
        end;
      end;
    end;

    if not Result then
      Exit;

    Inc(Value);
  end;

  if Result then
  begin
    Longitude := Env.Longitude.Center;
    LongitudeRange := Env.Longitude.Size * 0.5;

    Latitude := Env.Latitude.Center;
    LatitudeRange := Env.Latitude.Size * 0.5;
  end;

end;

class function TGeoHash.Verify(const Value: PChar): Boolean;
var
  I,CharCode: Integer;
  ValueLength: NativeInt;
  P: PChar;
  C: Char;
begin
  ValueLength := StrLen(Value);
  Result := ValueLength > 0;
  if not Result then
    Exit;

  P := Value;
  for I := 0 to ValueLength -1 do
  begin
    C := P^.ToUpper;
    CharCode := Ord(C);

    Result := (CharCode > 47); // 2F
    if Result then
    begin
      Dec(CharCode, 48);// 30

      Result := (CharCode > -1) and (CharCode < 69); // $43

      if Result then
        Result := BASE32_DECODE_TABLE[CharCode] <> -1;

    end;

    if not Result then
      Exit;

    Inc(P);
  end;
end;

class function TGeoHash.Decode(const Value: string; out Latitude,
  Longitude: Double): Boolean;
var
  RLat,RLon: Double;
begin
  Result := DecodeExactly(Value,Latitude,Longitude,RLat,RLon);

end;

class function TGeoHash.DecodeExactly(const Value: string; out Latitude,
  Longitude, LatitudeError, LongitudeError: Double): Boolean;
begin
  Result := DecodeExactly(PChar(Value),Latitude,Longitude,LatitudeError,LongitudeError);
end;

class function TGeoHash.Dimentions(const Hash: String; out Meters: Double): Boolean;
var
  Latitude,Longitude, LatitudeRangeSize,LongitudeRangeSize,
  A, C: Double;
begin
  Result := DecodeExactly(Hash,Latitude,Longitude,LatitudeRangeSize,LongitudeRangeSize);
  if Result then
  begin
    // https://en.wikipedia.org/wiki/Haversine_formula
    A := Sqr(Sin(DegToRad(LatitudeRangeSize * 0.5))) +
        ( Cos(DegToRad(Latitude - (LatitudeRangeSize * 0.5)) *
          Cos(DegToRad(Latitude + (LatitudeRangeSize * 0.5)))) ) *
         Sqr(Cos(DegToRad(LongitudeRangeSize * 0.5)));

    C := 2 * ArcTan2(Sqrt(A),Sqrt(1-A));

    Meters := 6371 * C * 0.001;
  end;
end;

class function TGeoHash.Encode(const Latitude, Longitude: Double; HashLength:
    NativeUInt = 12): string;
begin
  if not Encode(Latitude,Longitude,HashLength,Result) then
    Result := '';
end;

class function TGeoHash.HashLength(const Latitude1, Longitude1, Latitude2,
    Longitude2: Double): NativeInt;
var
  IsEven: Boolean;
  Bit: NativeInt;
  Mid, MinLat,MaxLat, MinLon, MaxLon: Double;
begin
  IsEven := True;
  MinLat := -90;
  MaxLat := 90;
  MinLon := -180;
  MaxLon := 180;
  Bit := 0;
  while Bit < MAX_BIT do
  begin

    if IsEven then
    begin
      Mid := (MinLon + MaxLon) * 0.5;
      if (Longitude1 >= Mid) then
      begin
        if Longitude2 < mid then
          Exit(Bit div BIT_DIV);

        MinLon := Mid;
      end
      else
      begin
        if (Longitude2 >= Mid) then
          Exit(Bit div BIT_DIV);

        MaxLon := Mid;
      end
    end
    else
    begin
      Mid := (MinLat + MaxLat) * 0.5;
      if Latitude1 >= Mid then
      begin
        if Latitude2 < Mid then
          Exit(Bit div BIT_DIV);

        MinLat := Mid;
      end
      else
      begin
        if (Latitude2 >= Mid) then
          Exit(Bit div BIT_DIV);

        MaxLat := Mid;
      end;
    end;

    IsEven := not IsEven;

    Inc(Bit);
  end;

  Result := MAX_HASH_LENGTH;
end;

class function TGeoHash.HeightDegrees(n: Integer): Double;
begin
  n := EnsureRange(n,0,MAX_HASH_LENGTH);
  Result := HASH_HEIGHTS[n];
end;

class function TGeoHash.HashLength(const Meters: Double): NativeInt;
begin
  Result := Floor(Log2(5000000/Meters)/2.5 + 1);

  if Result < 1 then
    Result := 1;

  if Result > MAX_HASH_LENGTH then
    Result := MAX_HASH_LENGTH;
end;

class function TGeoHash.Join(const Hash1, Hash2: string): string;
var
  I,J,Len: Integer;
begin
  Result := '';
  Len := Hash1.Length;
  if (Len > 0) then
  begin
    for I := 1 to Len -1 do
    begin
      J := 1 + Hash2.IndexOf(Hash1[I]);
      if (J > 0) and (J = I) then
        Result := Result + Hash2[J];
    end;
  end;
end;

class function TGeoHash.Adjacent(const Hash: string; Direction:
    TCardinalDirectionType): string;
var
  Len, Idx: NativeInt;
  Last: Char;
  Borders, Neighbor, Refined: string;
begin
  Result := '';
  Len := Hash.Length;
  if Len = 0 then
    Exit;

  Last := Hash[Len -1].ToLower;

  Idx := NativeInt(Direction) * 2 + (Len mod 2);

  Result := Copy(Hash, 1, Len -1);

  Borders := BORDERS_TABLE[Idx];
  if Borders.IndexOf(Last) > -1 then
  begin
    Refined := Adjacent(Result,Direction);
    if Refined = '' then
    begin
      Result := '';
      Exit;
    end;

    Result := Refined;
  end;

  Neighbor := NEIGHBORS_TABLE[Idx];
  Idx := Neighbor.IndexOf(Last);
  if Idx = -1 then
  begin
    Result := '';
    Exit;
  end;

  Result := Result + BASE32_ENCODE_TABLE[Idx];
end;

class function TGeoHash.Encode(const Latitude, Longitude: Double; HashLength:
    NativeUInt; out VResult: string): Boolean;
var
  I: NativeUInt;
  Bit: NativeInt;
  Lat,Lon, Mid,Tmp: Double;
  Area: TGeoHashEnvelope;
begin
  VResult := '';
  Result := ValidLatitude(Latitude) and ValidLongitude(Longitude);
  if not Result then
    Exit;


  Lon := Longitude;
  Lat := Latitude;

  if (HashLength < 1) or (HashLength > MAX_HASH_LENGTH) then
    HashLength := MAX_HASH_LENGTH;

  SetLength(VResult,HashLength);

  Area := TGeoHashEnvelope.InitialRange;

  I := 1;
  while I <= HashLength  do
  begin
    Bit := 0;

    SetBit(Lon,4,Area.Longitude,Bit,Mid);
    SetBit(Lat,3,Area.Latitude,Bit,Mid);
    SetBit(Lon,2,Area.Longitude,Bit,Mid);
    SetBit(Lat,1,Area.Latitude,Bit,Mid);
    SetBit(Lon,0,Area.Longitude,Bit,Mid);

    VResult[I] := BASE32_ENCODE_TABLE[Bit];

    Tmp := Lon;
    Lon := Lat;
    Lat := Tmp;

    Area := TGeoHashEnvelope.SwapRanges(Area);

    Inc(I);
  end;
end;

class procedure TGeoHash.RefineRange(var Range: TGeoHashRange; Bits: NativeInt;
    Offset: NativeInt);
begin
  if (Bits and Offset) = Offset then
    Range.Min :=  (Range.Max + Range.Min) /2
  else
    Range.Max :=  (Range.Max + Range.Min) /2
end;

class procedure TGeoHash.SetBit(AValue: Double; AOffset: NativeInt; var VRange:
    TGeoHashRange; var VBits: NativeInt; var VMid: Double);
begin
  VMid := (VRange.Max + VRange.Min) /2;

  if AValue >= VMid  then
  begin
    VRange.Min := VMid;
    VBits := VBits or ($1 shl AOffset);
  end
  else
  begin
    VRange.Max := VMid;
    VBits := VBits or ($0 shl AOffset);
  end;
end;

class function TGeoHash.ValidLatitude(const Value: Double): Boolean;
begin
  Result := (Value >= -90) and (Value <= 90);
end;

class function TGeoHash.ValidLongitude(const Value: Double): Boolean;
begin
  Result := (Value >= -180) and (Value <= 180);
end;

class function TGeoHash.Verify(const Value: string): Boolean;
begin
  Result := Verify(PChar(Value));
end;

class function TGeoHash.WidthDegrees(n: Integer): Double;
begin
  n := EnsureRange(n,0,MAX_HASH_LENGTH);
  Result := HASH_WIDTHS[n];
end;

class function TGeoHash.TGeoHashEnvelope.InitialRange: TGeoHashEnvelope;
begin
  Result.Latitude.Max := 90;
  Result.Latitude.Min := -90;
  Result.Longitude.Max := 180;
  Result.Longitude.Min := -180;
end;

class function TGeoHash.TGeoHashEnvelope.SwapRanges(const Source: TGeoHashEnvelope): TGeoHashEnvelope;
begin
  Result.Longitude := Source.Latitude;
  Result.Latitude := Source.Longitude;
end;

{ TGeoHashNeighbors }

procedure TGeoHashNeighbors.Clear;
begin
  Self.North := '';
  Self.East := '';
  Self.West := '';
  Self.South := '';

  Self.NorthEast := '';
  Self.NorthWest := '';
  Self.SouthEast := '';
  Self.SouthWest := '';
end;

constructor TGeoHashNeighbors.Create(const Hash: string);
begin
  Self.Clear();

  if Hash <> '' then
  begin
    Self.North := TGeoHash.Adjacent(Hash,cdtNorth);
    Self.East := TGeoHash.Adjacent(Hash,cdtEast);
    Self.West := TGeoHash.Adjacent(Hash,cdtWest);
    Self.South := TGeoHash.Adjacent(Hash,cdtSouth);

    Self.NorthEast := TGeoHash.Adjacent(Self.North,cdtEast);
    Self.NorthWest := TGeoHash.Adjacent(Self.North,cdtWest);
    Self.SouthEast := TGeoHash.Adjacent(Self.South,cdtEast);
    Self.SouthWest := TGeoHash.Adjacent(Self.South,cdtWest);
  end;
end;

class function TGeoHashNeighbors.CreateByHash(
  const Hash: string): TGeoHashNeighbors;
begin
  Result.Create(Hash);
end;

function TGeoHashNeighbors.ToString(Delimiter: string): string;
begin
  Result := Self.North;

  if (Result <> '') and (Self.NorthEast <> '') then
    Result := Result + Delimiter + Self.NorthEast;

  if (Result <> '') and (Self.East <> '') then
    Result := Result + Delimiter + Self.East;

  if (Result <> '') and (Self.SouthEast <> '') then
    Result := Result + Delimiter + Self.SouthEast;

  if (Result <> '') and (Self.South <> '') then
    Result := Result + Delimiter + South;

  if (Result <> '') and (Self.West <> '') then
    Result := Result + Delimiter + Self.West;

  if (Result <> '') and (Self.SouthWest <> '') then
    Result := Result + Delimiter + Self.SouthWest;

  if (Result <> '') and (Self.NorthWest <> '') then
    Result := Result + Delimiter + Self.NorthWest;
end;

{ TGeoHash.TGeoHashRange }

function TGeoHash.TGeoHashRange.Center: Double;
begin
  Result := (Max + Min) * 0.5;
end;

function TGeoHash.TGeoHashRange.Size: Double;
begin
  Result := Max - Min;
end;



initialization
  TGeoHash.calculateHashSizes;
end.

    'n',  'p',  'q',  'r',  's',
    't',  'u',  'v',  'w',
    'x',  'y',  'z');
    /// <summary>
    ///   The characters used in base 32 representations.
    /// </summary>
    BASE32_DECODE_TABLE: array[0..42] of Integer = (
    {0}   0, {1}   1, {2}   2, {3}   3, {4}   4,
    {5}   5, {6}   6, {7}   7, {8}   8, {9}   9,
    {:}  -1, {;}  -1, {<}  -1, {=}  -1, {>}  -1,
    {?}  -1, {@}  -1, {A}  -1, {B}  10, {C}  11,
    {D}  12, {E}  13, {F}  14, {G}  15, {H}  16,
    {I}  -1, {J}  17, {K}  18, {L}  -1, {M}  19,
    {N}  20, {O}  -1, {P}  21, {Q}  22, {R}  23,
    {S}  24, {T}  25, {U}  26, {V}  27, {W}  28,
    {X}  29, {Y}  30, {Z}  31
    );
    /// <summary>
    ///   Table for lookup for neighbouring hashes.
    /// </summary>
    NEIGHBORS_TABLE: array[0..7] of array[0..31] of Char = (
    // north even
    ('p','0','r','2','1','4','3','6','x','8','z','b','9','d','c','f','5','h','7','k','j','n','m','q','e','s','g','u','t','w','v','y'),
    // north odd
    ('b','c','0','1','f','g','4','5','2','3','8','9','6','7','d','e','u','v','h','j','y','z','n','p','k','m','s','t','q','r','w','x'),
    // east even
    ('b','c','0','1','f','g','4','5','2','3','8','9','6','7','d','e','u','v','h','j','y','z','n','p','k','m','s','t','q','r','w','x'),
    // east odd
    ('p','0','r','2','1','4','3','6','x','8','z','b','9','d','c','f','5','h','7','k','j','n','m','q','e','s','g','u','t','w','v','y'),
    // west even
    ('2','3','8','9','6','7','d','e','b','c','0','1','f','g','4','5','k','m','s','t','q','r','w','x','u','v','h','j','y','z','n','p'),
    // west odd
    ('1','4','3','6','5','h','7','k','9','d','c','f','e','s','g','u','j','n','m','q','p','0','r','2','t','w','v','y','x','8','z','b'),
    // south even
    ('1','4','3','6','5','h','7','k','9','d','c','f','e','s','g','u','j','n','m','q','p','0','r','2','t','w','v','y','x','8','z','b'),
    // south odd
    ('2','3','8','9','6','7','d','e','b','c','0','1','f','g','4','5','k','m','s','t','q','r','w','x','u','v','h','j','y','z','n','p')
    );
    /// <summary>
    ///   Table for lookup for hash borders.
    /// </summary>
    BORDERS_TABLE: array[0..7] of array[0..7] of Char = (
    // north even
      ('p','r','x','z',#0,#0,#0,#0),
    // north odd
      ('b','c','f','g','u','v','y','z'),
    // east even
      ('b','c','f','g','u','v','y','z'),
    // east odd
      ('p','r','x','z',#0,#0,#0,#0),
    // west even
      ('0','1','4','5','h','j','n','p'),
    // west odd
      ('0','2','8','b',#0,#0,#0,#0),
    // south even
      ('0','2','8','b',#0,#0,#0,#0),
    // south odd
      ('0','1','4','5','h','j','n','p')
    );
  type
    TGeoHashRange = record
      Min: Double;
      Max: Double;
    public
      function Size: Double; inline;
      function Center: Double; inline;
    end;

    TGeoHashEnvelope = record
      Latitude: TGeoHashRange;
      Longitude: TGeoHashRange;
    public
    class function InitialRange: TGeoHashEnvelope; static; inline;
    class function SwapRanges(const Source: TGeoHashEnvelope): TGeoHashEnvelope; static; inline;
    end;

  /// <summary>
  ///   Refines range by a factor or 2 in either the 0 or 1 ordinate.
  /// </summary>
  class procedure RefineRange(var Range: TGeoHashRange; Bits: NativeInt; Offset: NativeInt); static; inline;
  class procedure SetBit(AValue: Double; AOffset: NativeInt; var VRange: TGeoHashRange; var VBits: NativeInt; var VMid: Double); static; inline;
  class function ValidLatitude(const Value: Double): Boolean; static; inline;
  class function ValidLongitude(const Value: Double): Boolean; static; inline;
  public
    /// <summary>
    ///   Returns the adjacent hash for given direction
    /// </summary>
    /// <param name="Hash">
    ///   string hash relative to which the adjacent is returned
    /// </param>
    /// <param name="Direction">
    ///   direction relative to hash for which the adjacent is returned
    /// </param>
    /// <returns>
    ///   hash of adjacent hash
    /// </returns>
    class function Adjacent(const Hash: string; Direction: TCardinalDirectionType): string; static; inline;
    /// <summary>
    ///   Returns a latitude longitude pair as the centre of the given geohash
    ///   and hash envelope size.
    /// </summary>
    class function DecodeExactly(Value: PChar; out Latitude, Longitude,LatitudeRange, LongitudeRange: Double): Boolean; overload; static; inline;
    /// <summary>
    ///   Returns a latitude longitude pair as the centre of the given geohash
    ///   and hash envelope size.
    /// </summary>
    class function DecodeExactly(const Value: string; out Latitude, Longitude, LatitudeError, LongitudeError: Double): Boolean; overload; static; inline;
    /// <summary>
    ///   Returns a latitude,longitude pair as the centre of the given geohash.
    /// </summary>
    class function Decode(const Value: string; out Latitude, Longitude: Double): Boolean; overload; static; inline;
    /// <summary>
    ///   Returns a latitude,longitude pair as the centre of the given geohash.
    /// </summary>
    class function Decode(const Value: PChar; out Latitude, Longitude: Double): Boolean; overload; static; inline;
    /// <summary>
    ///   Returns the maximum length in degrees for hash given size. <br />
    /// </summary>
    class function Dimentions(const HashLength: NativeInt; out LatitudeRange, LongitudeRange: Double): Boolean; overload; static; inline;
    /// <summary>
    ///   Returns the maximum length bounding box in meters for given hash
    ///   string. <br />
    /// </summary>
    class function Dimentions(const Hash: string; out Meters: Double): Boolean; overload; static;
    /// <summary>
    ///   Make a geohash given length for the given Latitude and
    ///   Longitude.
    /// </summary>
    /// <param name="Latitude">
    ///   latitude
    /// </param>
    /// <param name="Longitude">
    ///   longitude <br />
    /// </param>
    /// <param name="HashLength">
    ///   length of hash string
    /// </param>
    /// <param name="VResult">
    ///   hash string
    /// </param>
    /// <returns>
    ///   true if success
    /// </returns>
    class function Encode(const Latitude, Longitude: Double; HashLength: NativeUInt; out VResult: string): Boolean; overload; static; inline;
    /// <summary>
    ///   Returns a geohash of given length for the given latitude and
    ///   longitude <br />
    /// </summary>
    /// <param name="Latitude">
    ///   latitude
    /// </param>
    /// <param name="Longitude">
    ///   longitude <br />
    /// </param>
    /// <param name="HashLength">
    ///   length of hash string
    /// </param>
    /// <returns>
    ///   hashstring
    /// </returns>
    class function Encode(const Latitude, Longitude: Double; HashLength: NativeUInt = 12): string; overload; static; inline;
    class function Joint(const Hash1,Hash2: string): string; static; inline;
    /// <summary>
    ///   Returns the max length of hash that covers given envelope in meters
    /// </summary>
    class function HashLength(const Meters: Double): NativeInt; overload; static; inline;
    /// <summary>
    ///   Returns the max length of hash that covers given envelope
    /// </summary>
    class function HashLength(const Latitude1, Longitude1, Latitude2, Longitude2: Double): NativeInt; overload; static; inline;
    /// <summary>
    ///   validate hash string
    /// </summary>
    class function Verify(const Value: PChar): Boolean; overload; static; inline;
    /// <summary>
    ///   validate hash string
    /// </summary>
    class function Verify(const Value: string): Boolean; overload; static; inline;
  end;

  TGeoHashNeighbors = record
    North,
    NorthEast,
    East,
    SouthEast,
    South,
    West,
    SouthWest,
    NorthWest: string;
  strict private
    procedure Clear();
  public
    constructor Create(const Hash: string); overload;
    class function CreateByHash(const Hash: string): TGeoHashNeighbors; static; inline;
    function ToString(Delimiter: string): string;
  end;


implementation

{ TGeoHash }

class function TGeoHash.Dimentions(const HashLength: NativeInt;
  out LatitudeRange, LongitudeRange: Double): Boolean;
var
  I, J: NativeInt;
begin
  Result := (HashLength > 0);
  if not Result then
    Exit;

  LongitudeRange := 360;
  LatitudeRange := 180;

	J := (HashLength * 5) div 2;
  for I := 0 to J -1 do
    LatitudeRange := LatitudeRange / 2;

  J := (HashLength * 5) div (2 + IfThen(Boolean(HashLength mod 2),1,0));
  for I := 0 to J -1 do
    LongitudeRange := LongitudeRange / 2;
end;

class function TGeoHash.Decode(const Value: PChar; out Latitude,
  Longitude: Double): Boolean;
var
  ErrLat,ErrLon: Double;
begin
  Result := DecodeExactly(Value,Latitude,Longitude,ErrLat,ErrLon);

end;

class function TGeoHash.DecodeExactly(Value: PChar; out Latitude, Longitude,
    LatitudeRange, LongitudeRange: Double): Boolean;
var
  I,CharCode: Integer;
  ValueLength: NativeInt;
  C: Char;
  Env: TGeoHashEnvelope;
begin
  Latitude := NaN;
  Longitude := NaN;
  LatitudeRange := NaN;
  LongitudeRange := NaN;


  ValueLength := StrLen(Value);
  Result := ValueLength > 0;
  if not Result then
    Exit;

  Env := TGeoHashEnvelope.InitialRange;
  for I := 0 to ValueLength -1 do
  begin
    C := Value^.ToUpper;
    CharCode := Ord(C);

    Result := (CharCode > 47); // 2F
    if Result then
    begin
      Dec(CharCode, 48);// $30

      Result := (CharCode > -1) and (CharCode < 69); // $43

      if Result then
      begin
        CharCode := BASE32_DECODE_TABLE[CharCode];
        Result := CharCode > -1;
        if Result then
        begin
          RefineRange(Env.Longitude, CharCode, 16);
          RefineRange(Env.Latitude, CharCode, 8);
          RefineRange(Env.Longitude, CharCode, 4);
          RefineRange(Env.Latitude, CharCode, 2);
          RefineRange(Env.Longitude, CharCode, 1);

          Env := TGeoHashEnvelope.SwapRanges(Env);
        end;
      end;
    end;

    if not Result then
      Exit;

    Inc(Value);
  end;

  if Result then
  begin
    Longitude := Env.Longitude.Center;
    LongitudeRange := Env.Longitude.Size * 0.5;

    Latitude := Env.Latitude.Center;
    LatitudeRange := Env.Latitude.Size * 0.5;
  end;

end;

class function TGeoHash.Verify(const Value: PChar): Boolean;
var
  I,CharCode: Integer;
  ValueLength: NativeInt;
  P: PChar;
  C: Char;
begin
  ValueLength := StrLen(Value);
  Result := ValueLength > 0;
  if not Result then
    Exit;

  P := Value;
  for I := 0 to ValueLength -1 do
  begin
    C := P^.ToUpper;
    CharCode := Ord(C);

    Result := (CharCode > 47); // 2F
    if Result then
    begin
      Dec(CharCode, 48);// 30

      Result := (CharCode > -1) and (CharCode < 69); // $43

      if Result then
        Result := BASE32_DECODE_TABLE[CharCode] <> -1;

    end;

    if not Result then
      Exit;

    Inc(P);
  end;
end;

class function TGeoHash.Decode(const Value: string; out Latitude,
  Longitude: Double): Boolean;
var
  RLat,RLon: Double;
begin
  Result := DecodeExactly(Value,Latitude,Longitude,RLat,RLon);

end;

class function TGeoHash.DecodeExactly(const Value: string; out Latitude,
  Longitude, LatitudeError, LongitudeError: Double): Boolean;
begin
  Result := DecodeExactly(PChar(Value),Latitude,Longitude,LatitudeError,LongitudeError);
end;

class function TGeoHash.Dimentions(const Hash: String; out Meters: Double): Boolean;
var
  Latitude,Longitude, LatitudeRangeSize,LongitudeRangeSize,
  A, C: Double;
begin
  Result := DecodeExactly(Hash,Latitude,Longitude,LatitudeRangeSize,LongitudeRangeSize);
  if Result then
  begin
    // https://en.wikipedia.org/wiki/Haversine_formula
    A := Sqr(Sin(DegToRad(LatitudeRangeSize * 0.5))) +
        ( Cos(DegToRad(Latitude - (LatitudeRangeSize * 0.5)) *
          Cos(DegToRad(Latitude + (LatitudeRangeSize * 0.5)))) ) *
         Sqr(Cos(DegToRad(LongitudeRangeSize * 0.5)));

    C := 2 * ArcTan2(Sqrt(A),Sqrt(1-A));

    Meters := 6371 * C * 0.001;
  end;
end;

class function TGeoHash.Encode(const Latitude, Longitude: Double; HashLength:
    NativeUInt = 12): string;
begin
  if not Encode(Latitude,Longitude,HashLength,Result) then
    Result := '';
end;

class function TGeoHash.HashLength(const Latitude1, Longitude1, Latitude2,
    Longitude2: Double): NativeInt;
const
  BIT_DIV = 5;
  MAX_BIT = MAX_HASH_LENGTH * BIT_DIV;
var
  IsEven: Boolean;
  Bit: NativeInt;
  Mid, MinLat,MaxLat, MinLon, MaxLon: Double;
begin
  IsEven := True;
  MinLat := -90;
  MaxLat := 90;
  MinLon := -180;
  MaxLon := 180;
  Bit := 0;
  while Bit < MAX_BIT do
  begin

    if IsEven then
    begin
      Mid := (MinLon + MaxLon) * 0.5;
      if (Longitude1 >= Mid) then
      begin
        if Longitude2 < mid then
          Exit(Bit div BIT_DIV);

        MinLon := Mid;
      end
      else
      begin
        if (Longitude2 >= Mid) then
          Exit(Bit div BIT_DIV);

        MaxLon := Mid;
      end
    end
    else
    begin
      Mid := (MinLat + MaxLat) * 0.5;
      if Latitude1 >= Mid then
      begin
        if Latitude2 < Mid then
          Exit(Bit div BIT_DIV);

        MinLat := Mid;
      end
      else
      begin
        if (Latitude2 >= Mid) then
          Exit(Bit div BIT_DIV);

        MaxLat := Mid;
      end;
    end;

    IsEven := not IsEven;

    Inc(Bit);
  end;

  Result := MAX_HASH_LENGTH;
end;

class function TGeoHash.HashLength(const Meters: Double): NativeInt;
begin
  Result := Floor(Log2(5000000/Meters)/2.5 + 1);

  if Result < 1 then
    Result := 1;

  if Result > MAX_HASH_LENGTH then
    Result := MAX_HASH_LENGTH;
end;

class function TGeoHash.Joint(const Hash1, Hash2: string): string;
var
  I,J,Len: Integer;
begin
  Result := '';
  Len := Hash1.Length;
  if (Len > 0) then
  begin
    for I := 1 to Len -1 do
    begin
      J := 1 + Hash2.IndexOf(Hash1[I]);
      if (J > 0) and (J = I) then
        Result := Result + Hash2[J];
    end;
  end;
end;

class function TGeoHash.Adjacent(const Hash: string; Direction:
    TCardinalDirectionType): string;
var
  Len, Idx: NativeInt;
  Last: Char;
  Borders, Neighbor, Refined: string;
begin
  Result := '';
  Len := Hash.Length;
  if Len = 0 then
    Exit;

  Last := Hash[Len -1].ToLower;

  Idx := NativeInt(Direction) * 2 + (Len mod 2);

  Result := Copy(Hash, 1, Len -1);

  Borders := BORDERS_TABLE[Idx];
  if Borders.IndexOf(Last) > -1 then
  begin
    Refined := Adjacent(Result,Direction);
    if Refined = '' then
    begin
      Result := '';
      Exit;
    end;

    Result := Refined;
  end;

  Neighbor := NEIGHBORS_TABLE[Idx];
  Idx := Neighbor.IndexOf(Last);
  if Idx = -1 then
  begin
    Result := '';
    Exit;
  end;

  Result := Result + BASE32_ENCODE_TABLE[Idx];
end;

class function TGeoHash.Encode(const Latitude, Longitude: Double; HashLength:
    NativeUInt; out VResult: string): Boolean;
var
  I: NativeUInt;
  Bit: NativeInt;
  Lat,Lon, Mid,Tmp: Double;
  Area: TGeoHashEnvelope;
begin
  VResult := '';
  Result := ValidLatitude(Latitude) and ValidLongitude(Longitude);
  if not Result then
    Exit;


  Lon := Longitude;
  Lat := Latitude;

  if (HashLength < 1) or (HashLength > MAX_HASH_LENGTH) then
    HashLength := MAX_HASH_LENGTH;

  SetLength(VResult,HashLength);

  Area := TGeoHashEnvelope.InitialRange;

  I := 1;
  while I <= HashLength  do
  begin
    Bit := 0;

    SetBit(Lon,4,Area.Longitude,Bit,Mid);
    SetBit(Lat,3,Area.Latitude,Bit,Mid);
    SetBit(Lon,2,Area.Longitude,Bit,Mid);
    SetBit(Lat,1,Area.Latitude,Bit,Mid);
    SetBit(Lon,0,Area.Longitude,Bit,Mid);

    VResult[I] := BASE32_ENCODE_TABLE[Bit];

    Tmp := Lon;
    Lon := Lat;
    Lat := Tmp;

    Area := TGeoHashEnvelope.SwapRanges(Area);

    Inc(I);
  end;
end;

class procedure TGeoHash.RefineRange(var Range: TGeoHashRange; Bits: NativeInt;
    Offset: NativeInt);
begin
  if (Bits and Offset) = Offset then
    Range.Min :=  (Range.Max + Range.Min) /2
  else
    Range.Max :=  (Range.Max + Range.Min) /2
end;

class procedure TGeoHash.SetBit(AValue: Double; AOffset: NativeInt; var VRange:
    TGeoHashRange; var VBits: NativeInt; var VMid: Double);
begin
  VMid := (VRange.Max + VRange.Min) /2;

  if AValue >= VMid  then
  begin
    VRange.Min := VMid;
    VBits := VBits or ($1 shl AOffset);
  end
  else
  begin
    VRange.Max := VMid;
    VBits := VBits or ($0 shl AOffset);
  end;
end;

class function TGeoHash.ValidLatitude(const Value: Double): Boolean;
begin
  Result := (Value >= -90) and (Value <= 90);
end;

class function TGeoHash.ValidLongitude(const Value: Double): Boolean;
begin
  Result := (Value >= -180) and (Value <= 180);
end;

class function TGeoHash.Verify(const Value: string): Boolean;
begin
  Result := Verify(PChar(Value));
end;

class function TGeoHash.TGeoHashEnvelope.InitialRange: TGeoHashEnvelope;
begin
  Result.Latitude.Max := 90;
  Result.Latitude.Min := -90;
  Result.Longitude.Max := 180;
  Result.Longitude.Min := -180;
end;

class function TGeoHash.TGeoHashEnvelope.SwapRanges(const Source: TGeoHashEnvelope): TGeoHashEnvelope;
begin
  Result.Longitude := Source.Latitude;
  Result.Latitude := Source.Longitude;
end;

{ TGeoHashNeighbors }

procedure TGeoHashNeighbors.Clear;
begin
  Self.North := '';
  Self.East := '';
  Self.West := '';
  Self.South := '';

  Self.NorthEast := '';
  Self.NorthWest := '';
  Self.SouthEast := '';
  Self.SouthWest := '';
end;

constructor TGeoHashNeighbors.Create(const Hash: string);
begin
  Self.Clear();

  if Hash <> '' then
  begin
    Self.North := TGeoHash.Adjacent(Hash,cdtNorth);
    Self.East := TGeoHash.Adjacent(Hash,cdtEast);
    Self.West := TGeoHash.Adjacent(Hash,cdtWest);
    Self.South := TGeoHash.Adjacent(Hash,cdtSouth);

    Self.NorthEast := TGeoHash.Adjacent(Self.North,cdtEast);
    Self.NorthWest := TGeoHash.Adjacent(Self.North,cdtWest);
    Self.SouthEast := TGeoHash.Adjacent(Self.South,cdtEast);
    Self.SouthWest := TGeoHash.Adjacent(Self.South,cdtWest);
  end;
end;

class function TGeoHashNeighbors.CreateByHash(
  const Hash: string): TGeoHashNeighbors;
begin
  Result.Create(Hash);
end;

function TGeoHashNeighbors.ToString(Delimiter: string): string;
begin
  Result := Self.North;

  if (Result <> '') and (Self.NorthEast <> '') then
    Result := Result + Delimiter + Self.NorthEast;

  if (Result <> '') and (Self.East <> '') then
    Result := Result + Delimiter + Self.East;

  if (Result <> '') and (Self.SouthEast <> '') then
    Result := Result + Delimiter + Self.SouthEast;

  if (Result <> '') and (Self.South <> '') then
    Result := Result + Delimiter + South;

  if (Result <> '') and (Self.West <> '') then
    Result := Result + Delimiter + Self.West;

  if (Result <> '') and (Self.SouthWest <> '') then
    Result := Result + Delimiter + Self.SouthWest;

  if (Result <> '') and (Self.NorthWest <> '') then
    Result := Result + Delimiter + Self.NorthWest;
end;

{ TGeoHash.TGeoHashRange }

function TGeoHash.TGeoHashRange.Center: Double;
begin
  Result := (Max + Min) * 0.5;
end;

function TGeoHash.TGeoHashRange.Size: Double;
begin
  Result := Max - Min;
end;

end.
