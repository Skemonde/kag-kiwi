u16 FindDigit(u16 number, u16 digit_position)
{
	u16 mlt = Maths::Pow(10, digit_position);
    return Maths::Floor(
        (number- Maths::Round(number/(mlt*10))*(mlt*10))
        /mlt);
}