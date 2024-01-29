'use client';
import { ApolloProvider, ApolloClient, InMemoryCache } from "@apollo/client"
import { NotificationProvider } from "@web3uikit/core";
import { LocalizationProvider } from "@mui/x-date-pickers";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";

export const client = new ApolloClient({
    cache: new InMemoryCache(),
    uri: "https://api.studio.thegraph.com/query/46831/thegraph_crowdfunding_/version/latest",
})

export function Providers({children}) {

    return(
        <ApolloProvider client={client}>
            <NotificationProvider>
                <LocalizationProvider dateAdapter={AdapterDayjs}>
                    {children}
                </LocalizationProvider>
            </NotificationProvider>
        </ApolloProvider>
    )
}