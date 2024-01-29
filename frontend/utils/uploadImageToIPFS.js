"use client"
import { create } from '@web3-storage/w3up-client'

export default async function uploadToIpfs(file) {
    const client = await create()
    const space = await client.createSpace('crowdfundingspaceimages')
    const myAccount = await client.login('raulmuelamorey@gmail.com')

    await myAccount.provision(space.did())

    await space.createRecovery(myAccount.did())

    await space.save()

    await client.setCurrentSpace(space.did())

    const directoryCid = await client.uploadFile(file)

    return directoryCid.toString()
    
}