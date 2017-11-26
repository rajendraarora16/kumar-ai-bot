/*
 * Copyright 2010-2015 the original author or authors.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package de.schildbach.pte;

import java.io.IOException;

import de.schildbach.pte.dto.Location;
import de.schildbach.pte.dto.LocationType;
import de.schildbach.pte.dto.SuggestLocationsResult;

import okhttp3.HttpUrl;

/**
 * @author Andreas Schildbach
 */
public class BvbProvider extends AbstractEfaProvider {
    private static final HttpUrl API_BASE = HttpUrl.parse("http://www.efa-bvb.ch/bvb/");

    public BvbProvider() {
        super(NetworkId.BVB, API_BASE);
    }

    @Override
    public SuggestLocationsResult suggestLocations(final CharSequence constraint) throws IOException {
        return xmlStopfinderRequest(new Location(LocationType.STATION, null, null, constraint.toString()));
    }
}
