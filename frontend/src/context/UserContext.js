import React, { createContext, useState, useEffect } from 'react';

export const  UserContext = createContext()

export const UserProvider = (props)=>{
    const[token, settoken] = useState(localStorage.getItem("studentToken"));
    useEffect(()=>{ 
        const fetchUser = async()=>{
            const requestOptions = {
                method:"GET",
                headers:{
                    "Content-Type": "application/json",
                    Authorization: "Bearer " + token,
                },
            }
            const response = await fetch("http://127.0.0.1:9002/student/", requestOptions)

            if(!response.ok)
            {
                settoken(null)
            }
            localStorage.setItem("studentToken", token);
        }
        fetchUser();
    },[token])

    return(
        <UserContext.Provider value={[token,settoken]}>
            {props.children}
        </UserContext.Provider>
    )
}
