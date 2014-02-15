DECLARE @Xml XML = '
<Root>
	<Data>In a strange city lying alone<BR/>Far down within the dim West<BR/><BR/>Where the good and the bad and the worst and the best<BR/>Have gone to their eternal rest.</Data>
</Root>'

SELECT @Xml

SELECT @Xml.query('
<Root>
	<Data>
		{
			for $x in /Root/Data/node()
			return
				if ($x[local-name(.)="BR"]) then
					text{"
"}
				else
					$x
		}
	</Data>
</Root>')
